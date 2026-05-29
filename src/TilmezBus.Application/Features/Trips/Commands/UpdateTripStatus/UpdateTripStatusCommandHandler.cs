using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Commands.UpdateTripStatus;

public class UpdateTripStatusCommandHandler : IRequestHandler<UpdateTripStatusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly ISignalRNotificationService _notificationService;
    private readonly IPushNotificationService _push;
    private readonly ILogger<UpdateTripStatusCommandHandler> _logger;

    public UpdateTripStatusCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        ISignalRNotificationService notificationService,
        IPushNotificationService push,
        ILogger<UpdateTripStatusCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _context = context;
        _notificationService = notificationService;
        _push = push;
        _logger = logger;
    }

    public async Task<Result> Handle(UpdateTripStatusCommand request, CancellationToken cancellationToken)
    {
        var trip = await _unitOfWork.Trips.GetByIdAsync(request.TripId, cancellationToken);
        if (trip is null) return Result.Failure("Trip not found.");

        var fromStatus = trip.Status;
        switch (request.NewStatus)
        {
            case TripStatus.InProgress: trip.Start(); break;
            case TripStatus.Completed: trip.Complete(); break;
            default: return Result.Failure("Invalid status transition.");
        }

        await _unitOfWork.Trips.UpdateAsync(trip);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // Scheduled → InProgress on a Return trip: students were left Waiting
        // when the trip was scheduled (the assistant hadn't picked them up
        // yet). Flip them all to Boarded with the live boarding time so the
        // recap reflects who actually started the journey.
        if (fromStatus == TripStatus.Scheduled
            && request.NewStatus == TripStatus.InProgress
            && trip.Type == TripType.Return)
        {
            var now = DateTime.UtcNow;
            var waiting = await _context.StudentTrips
                .Where(st => st.TripId == trip.Id
                             && st.BoardingStatus == BoardingStatus.Waiting)
                .ToListAsync(cancellationToken);
            foreach (var st in waiting)
            {
                st.BoardingStatus = BoardingStatus.Boarded;
                st.BoardingTime  = now;
            }
            if (waiting.Count > 0)
                await _context.SaveChangesAsync(cancellationToken);
        }

        // Scheduled → InProgress on either trip type: notify every parent
        // on the roster that the bus is rolling. The immediate-start path
        // (StartTripCommand with Scheduled=false) emits the same push
        // there; together they cover both ways a trip flips to live.
        if (fromStatus == TripStatus.Scheduled
            && request.NewStatus == TripStatus.InProgress)
        {
            await NotifyParentsTripStartedAsync(trip, cancellationToken);
        }

        // Morning trips end at the school, so completing the trip is the
        // same event as "all boarded students have arrived". Flip them to
        // DroppedOff so the recap reflects who actually made it, then
        // notify each parent that their kid arrived at school. Absent
        // students never reached BoardingStatus.Boarded so they're naturally
        // skipped — only riders who actually got on the bus are notified.
        if (request.NewStatus == TripStatus.Completed && trip.Type == TripType.Morning)
        {
            var now = DateTime.UtcNow;
            var boarded = await _context.StudentTrips
                .Where(st => st.TripId == trip.Id
                             && st.BoardingStatus == BoardingStatus.Boarded)
                .ToListAsync(cancellationToken);
            foreach (var st in boarded)
            {
                st.BoardingStatus = BoardingStatus.DroppedOff;
                st.DropoffTime ??= now;
            }
            if (boarded.Count > 0)
            {
                await _context.SaveChangesAsync(cancellationToken);

                // Build (studentName, parentUserId) tuples for everyone we just
                // dropped at school, then send one push per parent.
                var studentIds = boarded.Select(b => b.StudentId).ToList();
                var arrivals = await _context.Students
                    .Where(s => studentIds.Contains(s.Id))
                    .Select(s => new
                    {
                        s.FullName,
                        ParentUserId = s.Parent != null ? s.Parent.UserId : null,
                    })
                    .ToListAsync(cancellationToken);

                foreach (var a in arrivals)
                {
                    if (string.IsNullOrEmpty(a.ParentUserId)) continue;
                    try
                    {
                        // SendTemplatedToUserAsync picks the right language
                        // per registered device, writes the inbox row, and
                        // pushes via FCM. Per-parent failures are swallowed
                        // so one stale device doesn't block the others.
                        await _push.SendTemplatedToUserAsync(
                            a.ParentUserId,
                            NotificationType.StudentArrivedAtSchool,
                            new Dictionary<string, string?>
                            {
                                ["studentName"] = a.FullName,
                            },
                            new Dictionary<string, string>
                            {
                                ["type"] = "StudentArrivedAtSchool",
                                ["tripId"] = trip.Id.ToString(),
                            },
                            relatedTripId: trip.Id,
                            cancellationToken: cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex,
                            "StudentArrivedAtSchool push failed for student={Student} parent={Parent}",
                            a.FullName, a.ParentUserId);
                    }
                }
            }
        }

        // Mirror of the Morning block for Return trips: any student still
        // Boarded when the assistant taps Complete gets flipped to
        // DroppedOff and their parent gets StudentArrived ("arrived home").
        // Students manually marked DroppedOff earlier already fired the
        // same push from UpdateBoardingStatusCommandHandler, so they're
        // not in the `boarded` set we iterate here — no double banner.
        if (request.NewStatus == TripStatus.Completed && trip.Type == TripType.Return)
        {
            var now = DateTime.UtcNow;
            var boarded = await _context.StudentTrips
                .Where(st => st.TripId == trip.Id
                             && st.BoardingStatus == BoardingStatus.Boarded)
                .ToListAsync(cancellationToken);
            foreach (var st in boarded)
            {
                st.BoardingStatus = BoardingStatus.DroppedOff;
                st.DropoffTime ??= now;
            }
            if (boarded.Count > 0)
            {
                await _context.SaveChangesAsync(cancellationToken);

                var studentIds = boarded.Select(b => b.StudentId).ToList();
                var arrivals = await _context.Students
                    .Where(s => studentIds.Contains(s.Id))
                    .Select(s => new
                    {
                        s.FullName,
                        ParentUserId = s.Parent != null ? s.Parent.UserId : null,
                    })
                    .ToListAsync(cancellationToken);

                foreach (var a in arrivals)
                {
                    if (string.IsNullOrEmpty(a.ParentUserId)) continue;
                    try
                    {
                        await _push.SendTemplatedToUserAsync(
                            a.ParentUserId,
                            NotificationType.StudentArrived,
                            new Dictionary<string, string?>
                            {
                                ["studentName"] = a.FullName,
                            },
                            new Dictionary<string, string>
                            {
                                ["type"]   = "StudentArrived",
                                ["tripId"] = trip.Id.ToString(),
                            },
                            relatedTripId: trip.Id,
                            cancellationToken: cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex,
                            "StudentArrived (return-completion) push failed for student={Student} parent={Parent}",
                            a.FullName, a.ParentUserId);
                    }
                }
            }
        }

        // SignalR broadcasts are best-effort — a hub failure must not roll back a persisted status change.
        try
        {
            await _notificationService.SendTripStatusUpdateAsync(trip.Id, request.NewStatus.ToString(), cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "TripStatusUpdated broadcast failed for {TripId} → {Status}", trip.Id, request.NewStatus);
        }

        return Result.Success();
    }

    /// <summary>
    /// ParentTripStarted fan-out: one push per parent of any student on
    /// this trip's roster. Per-parent failures are swallowed so a single
    /// dead device can't block the others.
    /// </summary>
    private async Task NotifyParentsTripStartedAsync(
        Domain.Entities.Trip trip, CancellationToken ct)
    {
        var plate = await _context.Buses
            .Where(b => b.Id == trip.BusId)
            .Select(b => b.PlateNumber)
            .FirstOrDefaultAsync(ct) ?? string.Empty;

        var parentUserIds = await _context.StudentTrips
            .Where(st => st.TripId == trip.Id)
            .Join(_context.Students,
                st => st.StudentId, s => s.Id,
                (st, s) => s)
            .Where(s => s.Parent != null && s.Parent.UserId != null)
            .Select(s => s.Parent!.UserId!)
            .Distinct()
            .ToListAsync(ct);

        var tripTypeLabelAr = trip.Type == TripType.Morning ? "رحلة الصباح" : "رحلة العودة";
        var tripTypeLabelEn = trip.Type == TripType.Morning ? "Morning trip" : "Return trip";

        foreach (var parentUserId in parentUserIds)
        {
            try
            {
                await _push.SendTemplatedToUserAsync(
                    parentUserId,
                    NotificationType.ParentTripStarted,
                    new Dictionary<string, string?>
                    {
                        ["busPlateNumber"] = plate,
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
                    "[UpdateTripStatus] ParentTripStarted push failed for parent={Parent} trip={Trip}",
                    parentUserId, trip.Id);
            }
        }
    }
}
