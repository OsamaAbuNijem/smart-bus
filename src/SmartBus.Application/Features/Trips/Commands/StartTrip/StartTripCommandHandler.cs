using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Notifications.Commands.SendNotification;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Commands.StartTrip;

public class StartTripCommandHandler
    : IRequestHandler<StartTripCommand, Result<StartTripResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly IMediator _mediator;
    private readonly ILogger<StartTripCommandHandler> _logger;

    public StartTripCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        ICurrentUserService currentUser,
        IMediator mediator,
        ILogger<StartTripCommandHandler> logger)
    {
        _unitOfWork  = unitOfWork;
        _context     = context;
        _currentUser = currentUser;
        _mediator    = mediator;
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

        // Block opening a second trip while the assistant is mid-trip on
        // any bus / leg — finishing or completing the active one is the
        // only way out. Resolves the assistant by the JWT user id; admins
        // and drivers using this endpoint directly aren't affected.
        var callerUserId = _currentUser.UserId;
        if (!string.IsNullOrEmpty(callerUserId))
        {
            var caller = await _context.Drivers
                .FirstOrDefaultAsync(d => d.UserId == callerUserId, ct);
            if (caller is not null && caller.DriverType == DriverType.Assistant)
            {
                var liveBusIds = await _context.BusSchedules
                    .Where(s => s.MorningAssistantId == caller.Id ||
                                s.ReturnAssistantId  == caller.Id)
                    .Select(s => s.BusId)
                    .ToListAsync(ct);

                if (liveBusIds.Count > 0)
                {
                    var hasLive = await _context.Trips.AnyAsync(t =>
                        !t.IsTemplate &&
                        t.Status == TripStatus.InProgress &&
                        liveBusIds.Contains(t.BusId), ct);

                    if (hasLive)
                    {
                        return Result<StartTripResponse>.Failure(
                            "You already have an active trip. End it before starting a new one.");
                    }
                }
            }
        }

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
        var trip = new Trip
        {
            BusId              = bus.Id,
            Type               = request.TripType,
            Name               = $"{bus.PlateNumber} — {typeLabel} — {today:dd/MM/yyyy}",
            ScheduledDeparture = now,
            ActualDeparture    = now,
            Status             = TripStatus.InProgress,
            RepeatDays         = 0,
            IsTemplate         = false
        };
        await _unitOfWork.Trips.AddAsync(trip, ct);
        await _unitOfWork.SaveChangesAsync(ct);

        // Roster: prefer most recent prior trip on (bus, type); fall back to
        // the BusSchedule's assigned students.
        var lastTripId = await _context.Trips
            .Where(t => !t.IsTemplate
                        && t.Id    != trip.Id
                        && t.BusId == bus.Id
                        && t.Type  == request.TripType)
            .OrderByDescending(t => t.ScheduledDeparture)
            .Select(t => (Guid?)t.Id)
            .FirstOrDefaultAsync(ct);

        List<Guid> studentIds;
        if (lastTripId is not null)
        {
            studentIds = await _context.StudentTrips
                .Where(st => st.TripId == lastTripId)
                .Select(st => st.StudentId)
                .ToListAsync(ct);
        }
        else
        {
            studentIds = await _context.BusScheduleStudents
                .Where(x => x.BusSchedule.BusId == bus.Id)
                .Select(x => x.StudentId)
                .ToListAsync(ct);
        }

        // Return trips start with everyone already on the bus (the assistant
        // collected them at school), so seed Boarded with a boarding time
        // stamped at trip start. Morning trips begin with everyone Waiting
        // and the assistant marks each pickup as it happens.
        var initial = request.TripType == TripType.Return
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

        // Tell the driver the trip is live — shows up in their notifications
        // list and triggers a SignalR push so a logged-in driver app reacts
        // immediately. Best-effort: a notification failure shouldn't fail
        // the trip creation itself.
        if (!string.IsNullOrEmpty(driver.UserId))
        {
            try
            {
                var legLabel = request.TripType == TripType.Morning
                    ? "Morning pickup"
                    : "Return drop-off";
                await _mediator.Send(new SendNotificationCommand(
                    Title: $"{legLabel} started",
                    Message:
                        $"Bus {bus.PlateNumber} is now live — open the route map to begin driving.",
                    Type: NotificationType.TripStarted,
                    RecipientId: driver.UserId,
                    RelatedTripId: trip.Id,
                    RelatedBusId: bus.Id), ct);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex,
                    "[StartTrip] Failed to notify driver {DriverId}", driver.Id);
            }
        }

        return Result<StartTripResponse>.Success(new StartTripResponse(
            trip.Id, bus.Id, bus.PlateNumber,
            request.TripType.ToString(), studentIds.Count));
    }
}
