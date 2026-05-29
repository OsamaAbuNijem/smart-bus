using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.StudentTrips.Commands.UpdateBoardingStatus;

public class UpdateBoardingStatusCommandHandler
    : IRequestHandler<UpdateBoardingStatusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly IPushNotificationService _push;
    private readonly ILogger<UpdateBoardingStatusCommandHandler> _logger;

    public UpdateBoardingStatusCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        IPushNotificationService push,
        ILogger<UpdateBoardingStatusCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
        _push       = push;
        _logger     = logger;
    }

    public async Task<Result> Handle(
        UpdateBoardingStatusCommand request, CancellationToken ct)
    {
        var studentTrip = await _unitOfWork.StudentTrips
            .GetByStudentAndTripAsync(request.StudentId, request.TripId, ct);

        // Snapshot the previous status so we can detect a "first time" flip
        // (Waiting → Boarded for Morning, Boarded → DroppedOff for Return)
        // and avoid firing duplicate notifications on repeated taps.
        var previousStatus = studentTrip?.BoardingStatus;

        if (studentTrip is null)
        {
            studentTrip = new StudentTrip
            {
                StudentId      = request.StudentId,
                TripId         = request.TripId,
                BoardingStatus = request.Status,
                BoardingTime   = request.BoardingTime
                    ?? (request.Status == BoardingStatus.Boarded ? DateTime.UtcNow : null),
                DropoffTime    = request.Status == BoardingStatus.DroppedOff
                    ? DateTime.UtcNow
                    : null,
            };
            await _unitOfWork.StudentTrips.AddAsync(studentTrip, ct);
        }
        else
        {
            studentTrip.BoardingStatus = request.Status;
            if (request.BoardingTime.HasValue) studentTrip.BoardingTime = request.BoardingTime;
            // Stamp the drop-off moment the first time the student goes
            // DroppedOff. Reverting back to Boarded clears it so the
            // history reflects the current truth.
            if (request.Status == BoardingStatus.DroppedOff)
            {
                studentTrip.DropoffTime ??= DateTime.UtcNow;
            }
            else if (studentTrip.DropoffTime is not null
                     && request.Status != BoardingStatus.DroppedOff)
            {
                studentTrip.DropoffTime = null;
            }
            await _unitOfWork.StudentTrips.UpdateAsync(studentTrip);
        }

        // On Morning pickups capture the boarding GPS as the student's home
        // pickup point — but ONLY when we don't already have one on file.
        // Subsequent pickups don't overwrite, otherwise a noisy simulator
        // GPS or a parent dropping the kid off in a different spot would
        // permanently destroy the canonical home address.
        if (request.Status == BoardingStatus.Boarded
            && request.Latitude is double lat
            && request.Longitude is double lng)
        {
            var trip = await _context.Trips
                .Where(t => t.Id == request.TripId)
                .Select(t => new { t.Type })
                .FirstOrDefaultAsync(ct);

            if (trip is not null && trip.Type == TripType.Morning)
            {
                var student = await _context.Students
                    .FirstOrDefaultAsync(s => s.Id == request.StudentId, ct);
                if (student is not null
                    && student.Latitude is null
                    && student.Longitude is null)
                {
                    student.Latitude  = lat;
                    student.Longitude = lng;
                }
            }
        }

        await _unitOfWork.SaveChangesAsync(ct);

        // Parent push: notify on the first meaningful transition only.
        // Boarded transition → "picked up" confirmation, on any trip type
        //   (parents care about both the Morning school-pickup and the
        //   Return school-pickup-for-going-home).
        // DroppedOff transition on a Return trip → "arrived home" push.
        // Morning trip completion sends its own StudentArrivedAtSchool
        // push from UpdateTripStatusCommandHandler, so we don't duplicate
        // a drop-off banner here for Morning.
        var isPickup =
            request.Status == BoardingStatus.Boarded
            && previousStatus != BoardingStatus.Boarded;
        var isDropoff =
            request.Status == BoardingStatus.DroppedOff
            && previousStatus != BoardingStatus.DroppedOff;
        if (isPickup || isDropoff)
        {
            var trip = await _context.Trips
                .Where(t => t.Id == request.TripId)
                .Select(t => new { t.Id, t.Type })
                .FirstOrDefaultAsync(ct);

            // Drop-off push is Return-only (Morning's recap fires from
            // UpdateTripStatusCommand). Pickup push fires on either type.
            var shouldNotify = trip is not null && (
                isPickup
                || (isDropoff && trip.Type == TripType.Return));

            if (shouldNotify)
            {
                var info = await _context.Students
                    .Where(s => s.Id == request.StudentId)
                    .Select(s => new
                    {
                        s.FullName,
                        ParentUserId = s.Parent != null ? s.Parent.UserId : null,
                    })
                    .FirstOrDefaultAsync(ct);

                if (info?.ParentUserId is not null)
                {
                    var type = isPickup
                        ? NotificationType.StudentBoarded
                        : NotificationType.StudentArrived;
                    try
                    {
                        // Per-device language picking — each registered
                        // phone sees the template rendered in the language
                        // it last registered with. Inbox row + FCM push
                        // both happen inside SendTemplatedToUserAsync.
                        await _push.SendTemplatedToUserAsync(
                            info.ParentUserId,
                            type,
                            new Dictionary<string, string?>
                            {
                                ["studentName"] = info.FullName,
                            },
                            new Dictionary<string, string>
                            {
                                ["type"]   = type.ToString(),
                                ["tripId"] = trip!.Id.ToString(),
                            },
                            relatedTripId: trip!.Id,
                            cancellationToken: ct);
                    }
                    catch (System.Exception ex)
                    {
                        _logger.LogWarning(ex,
                            "[UpdateBoarding] {Type} push failed for student={Student} parent={Parent}",
                            type, info.FullName, info.ParentUserId);
                    }
                }
            }
        }

        return Result.Success();
    }
}
