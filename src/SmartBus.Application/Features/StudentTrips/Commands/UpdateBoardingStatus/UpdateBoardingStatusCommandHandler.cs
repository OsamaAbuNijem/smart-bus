using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Notifications.Commands.SendNotification;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.StudentTrips.Commands.UpdateBoardingStatus;

public class UpdateBoardingStatusCommandHandler
    : IRequestHandler<UpdateBoardingStatusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly IMediator _mediator;

    public UpdateBoardingStatusCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        IMediator mediator)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
        _mediator   = mediator;
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
        // Morning trips → pickup confirmation when the student boards.
        // Return trips → drop-off confirmation when the student gets off.
        var isMorningPickup =
            request.Status == BoardingStatus.Boarded
            && previousStatus != BoardingStatus.Boarded;
        var isReturnDropoff =
            request.Status == BoardingStatus.DroppedOff
            && previousStatus != BoardingStatus.DroppedOff;
        if (isMorningPickup || isReturnDropoff)
        {
            var trip = await _context.Trips
                .Where(t => t.Id == request.TripId)
                .Select(t => new { t.Id, t.Type })
                .FirstOrDefaultAsync(ct);

            if (trip is not null &&
                ((trip.Type == TripType.Morning && isMorningPickup) ||
                 (trip.Type == TripType.Return  && isReturnDropoff)))
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
                    var (title, message, type) = isMorningPickup
                        ? ("Bus pickup",
                           $"{info.FullName} has been picked up by the bus.",
                           NotificationType.StudentBoarded)
                        : ("Arrived home",
                           $"{info.FullName} has been dropped off by the bus.",
                           NotificationType.StudentArrived);

                    await _mediator.Send(
                        new SendNotificationCommand(
                            title, message, type,
                            info.ParentUserId, trip.Id, null),
                        ct);
                }
            }
        }

        return Result.Success();
    }
}
