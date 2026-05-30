using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Notifications.Commands.SendNotification;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Commands.StartTrip;

public class StartTripCommandHandler
    : IRequestHandler<StartTripCommand, Result<StartTripResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly IMediator _mediator;
    private readonly INotificationTemplateService _templates;
    private readonly IPushNotificationService _push;
    private readonly ILogger<StartTripCommandHandler> _logger;

    public StartTripCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        ICurrentUserService currentUser,
        IMediator mediator,
        INotificationTemplateService templates,
        IPushNotificationService push,
        ILogger<StartTripCommandHandler> logger)
    {
        _unitOfWork  = unitOfWork;
        _context     = context;
        _currentUser = currentUser;
        _mediator    = mediator;
        _templates   = templates;
        _push        = push;
        _logger      = logger;
    }

    public async Task<Result<StartTripResponse>> Handle(
        StartTripCommand request, CancellationToken ct)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, ct);
        if (bus is null)
            return Result<StartTripResponse>.Failure("Bus not found.");

        var driver = await _context.Drivers
            .FirstOrDefaultAsync(d => d.Id == request.DriverId, ct);
        if (driver is null || driver.DriverType != DriverType.Driver)
            return Result<StartTripResponse>.Failure("Driver not found.");

        // Resolve the caller's Driver row once — used both for the
        // "one pending trip per assistant" guard below and to stamp the
        // trip's AssistantId when the caller is an Assistant.
        var callerUserId = _currentUser.UserId;
        Driver? caller = null;
        if (!string.IsNullOrEmpty(callerUserId))
        {
            caller = await _context.Drivers
                .FirstOrDefaultAsync(d => d.UserId == callerUserId, ct);
        }

        // Block opening a second trip while the assistant already has one
        // pending or live on any bus in their school. The assistant must
        // either start the Scheduled trip and finish it, or delete it,
        // before creating a new one. Drivers and admins bypass this check.
        if (caller is not null && caller.DriverType == DriverType.Assistant)
        {
            var schoolBusIds = caller.SchoolId is null
                ? new List<Guid>()
                : await _context.Buses
                    .Where(b => b.SchoolId == caller.SchoolId && !b.IsDeleted)
                    .Select(b => b.Id)
                    .ToListAsync(ct);

            if (schoolBusIds.Count > 0)
            {
                var hasPending = await _context.Trips.AnyAsync(t =>
                    !t.IsTemplate
                    && (t.Status == TripStatus.Scheduled ||
                        t.Status == TripStatus.InProgress)
                    && schoolBusIds.Contains(t.BusId), ct);
                if (hasPending)
                {
                    return Result<StartTripResponse>.Failure(
                        "You already have a pending or active trip. Start or delete it before creating a new one.");
                }
            }
        }

        var assistantId = caller is { DriverType: DriverType.Assistant }
            ? caller.Id
            : (Guid?)null;

        // Idempotency: if a non-completed trip exists today for (bus, type),
        // reuse it instead of creating a duplicate.
        var today    = DateTime.UtcNow.Date;
        var tomorrow = today.AddDays(1);
        var existing = await _context.Trips
            .Where(t => !t.IsTemplate
                        && t.BusId == bus.Id
                        && t.Type  == request.TripType
                        && t.Status != TripStatus.Completed
                        && t.ScheduledDeparture >= today
                        && t.ScheduledDeparture <  tomorrow)
            .FirstOrDefaultAsync(ct);

        if (existing is not null)
        {
            var existingCount = await _context.StudentTrips
                .CountAsync(st => st.TripId == existing.Id, ct);
            return Result<StartTripResponse>.Success(new StartTripResponse(
                existing.Id, bus.Id, bus.PlateNumber,
                request.TripType.ToString(), existingCount));
        }

        var now = DateTime.UtcNow;
        var typeLabel = request.TripType == TripType.Morning ? "ذهاب" : "إياب";
        // Scheduled trips are materialised without an ActualDeparture; the
        // assistant taps "Start" later (UpdateTripStatusCommand) to flip the
        // trip to InProgress and stamp ActualDeparture then. The handler still
        // creates the roster up-front so the assistant can review it.
        var trip = new Trip
        {
            BusId              = bus.Id,
            SchoolId           = bus.SchoolId,
            DriverId           = driver.Id,
            AssistantId        = assistantId,
            Type               = request.TripType,
            Name               = $"{bus.PlateNumber} — {typeLabel} — {today:dd/MM/yyyy}",
            ScheduledDeparture = now,
            ActualDeparture    = request.Scheduled ? null : now,
            Status             = request.Scheduled
                                    ? TripStatus.Scheduled
                                    : TripStatus.InProgress,
            RepeatDays         = 0,
            IsTemplate         = false
        };
        await _unitOfWork.Trips.AddAsync(trip, ct);
        await _unitOfWork.SaveChangesAsync(ct);

        // Roster precedence: SkipRoster (explicit empty) → ManualStudentIds
        // (hand-picked) → last trip on (bus, type). BusSchedule fallback is
        // gone with the table.
        List<Guid> studentIds;
        if (request.SkipRoster)
        {
            studentIds = new List<Guid>();
        }
        else if (request.ManualStudentIds is { Count: > 0 } manualIds)
        {
            // Deduplicate + ignore anything the caller passed that doesn't
            // resolve to a live, non-deleted student.
            var distinct = manualIds.Distinct().ToList();
            studentIds = await _context.Students
                .Where(s => !s.IsDeleted && distinct.Contains(s.Id))
                .Select(s => s.Id)
                .ToListAsync(ct);
        }
        else
        {
            var lastTripId = await _context.Trips
                .Where(t => !t.IsTemplate
                            && t.Id    != trip.Id
                            && t.BusId == bus.Id
                            && t.Type  == request.TripType)
                .OrderByDescending(t => t.ScheduledDeparture)
                .Select(t => (Guid?)t.Id)
                .FirstOrDefaultAsync(ct);

            studentIds = lastTripId is not null
                ? await _context.StudentTrips
                    .Where(st => st.TripId == lastTripId)
                    .Select(st => st.StudentId)
                    .ToListAsync(ct)
                : new List<Guid>();
        }

        // Reject empty rosters unless the caller explicitly opted in via
        // SkipRoster. The trip-setup screen now enforces this client-side
        // too, but the server guard prevents a stray empty trip from any
        // other caller (older mobile build, API misuse).
        if (studentIds.Count == 0 && !request.SkipRoster)
        {
            return Result<StartTripResponse>.Failure(
                "Cannot start an empty trip — add at least one student.");
        }

        // Return trips start with everyone already on the bus (the assistant
        // collected them at school), so seed Boarded with a boarding time
        // stamped at trip start. Morning trips begin with everyone Waiting
        // and the assistant marks each pickup as it happens. For Scheduled
        // trips we leave EVERY row Waiting and let the activate step seed
        // the Return-trip boarding when the assistant taps Start.
        var initial = (!request.Scheduled && request.TripType == TripType.Return)
            ? BoardingStatus.Boarded
            : BoardingStatus.Waiting;
        foreach (var sid in studentIds)
        {
            _context.StudentTrips.Add(new StudentTrip
            {
                TripId         = trip.Id,
                StudentId      = sid,
                BoardingStatus = initial,
                BoardingTime   = initial == BoardingStatus.Boarded ? now : null,
            });
        }
        if (studentIds.Count > 0)
            await _context.SaveChangesAsync(ct);

        _logger.LogInformation(
            "[StartTrip] Bus={BusId} Driver={DriverId} Type={Type} Students={N} → Trip {TripId}",
            bus.Id, driver.Id, request.TripType, studentIds.Count, trip.Id);

        // Tell the driver the trip is live. Goes through the same
        // SendToUserAsync path as the SuperAdmin broadcast (proven to
        // reach the driver phone) rather than the older SignalR-then-FCM
        // path, which was being intercepted before FCM in this driver's
        // case. Suppressed for Scheduled trips — those fire the "trip
        // started" push from UpdateTripStatusCommand instead.
        if (!request.Scheduled && !string.IsNullOrEmpty(driver.UserId))
        {
            try
            {
                var (title, message) = await _templates.RenderAsync(
                    NotificationType.TripStarted,
                    "ar",
                    new Dictionary<string, string?>
                    {
                        ["busPlateNumber"] = bus.PlateNumber,
                        ["tripType"] = request.TripType == TripType.Morning
                            ? "رحلة الصباح"
                            : "رحلة العودة",
                    },
                    ct);
                await _push.SendToUserAsync(
                    driver.UserId,
                    title,
                    message,
                    NotificationType.TripStarted,
                    data: new Dictionary<string, string>
                    {
                        ["type"]   = "TripStarted",
                        ["tripId"] = trip.Id.ToString(),
                        ["busId"]  = bus.Id.ToString(),
                    },
                    cancellationToken: ct);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex,
                    "[StartTrip] Failed to notify driver {DriverId}", driver.Id);
            }
        }

        // Notify parents only when the trip is going live now (not when
        // it's being scheduled for later — the Scheduled → InProgress
        // transition fires the same push from UpdateTripStatusCommand).
        if (!request.Scheduled && studentIds.Count > 0)
        {
            await NotifyParentsTripStartedAsync(
                studentIds, trip, bus.PlateNumber, ct);
        }

        return Result<StartTripResponse>.Success(new StartTripResponse(
            trip.Id, bus.Id, bus.PlateNumber,
            request.TripType.ToString(), studentIds.Count));
    }

    /// <summary>
    /// Send ParentTripStarted to the parent of every student on the
    /// roster. Per-parent failures are swallowed so a single dead device
    /// can't block the others (and certainly can't fail the trip start).
    /// </summary>
    private async Task NotifyParentsTripStartedAsync(
        List<Guid> studentIds, Trip trip, string busPlateNumber, CancellationToken ct)
    {
        var parents = await _context.Students
            .Where(s => studentIds.Contains(s.Id) && s.Parent != null)
            .Select(s => new
            {
                StudentId = s.Id,
                ParentUserId = s.Parent!.UserId,
            })
            .Where(x => x.ParentUserId != null)
            .Distinct()
            .ToListAsync(ct);

        // Deduplicate by parent — one parent with multiple kids on this
        // trip should only see one banner, not one per kid.
        var distinctParents = parents
            .Select(p => p.ParentUserId!)
            .Distinct()
            .ToList();

        var tripTypeLabelAr = trip.Type == TripType.Morning
            ? "رحلة الصباح" : "رحلة العودة";
        var tripTypeLabelEn = trip.Type == TripType.Morning
            ? "Morning trip" : "Return trip";

        foreach (var parentUserId in distinctParents)
        {
            try
            {
                // SendTemplatedToUserAsync picks the right language per
                // registered device, writes the inbox row, and pushes
                // via FCM. {tripType} is rendered per-language inside
                // the template service — we hand both labels through
                // and the active locale chooses one.
                await _push.SendTemplatedToUserAsync(
                    parentUserId,
                    NotificationType.ParentTripStarted,
                    new Dictionary<string, string?>
                    {
                        ["busPlateNumber"] = busPlateNumber,
                        ["tripType"]       = tripTypeLabelAr,
                        ["tripTypeEn"]     = tripTypeLabelEn,
                    },
                    new Dictionary<string, string>
                    {
                        ["type"]   = "ParentTripStarted",
                        ["tripId"] = trip.Id.ToString(),
                        ["busId"]  = trip.BusId.ToString(),
                    },
                    relatedTripId: trip.Id,
                    relatedBusId:  trip.BusId,
                    cancellationToken: ct);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex,
                    "[StartTrip] ParentTripStarted push failed for parent={Parent} trip={Trip}",
                    parentUserId, trip.Id);
            }
        }
    }
}
