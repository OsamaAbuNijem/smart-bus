using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.StudentTrips.Commands.UpdateBoardingStatus;

public class UpdateBoardingStatusCommandHandler
    : IRequestHandler<UpdateBoardingStatusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public UpdateBoardingStatusCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
    }

    public async Task<Result> Handle(
        UpdateBoardingStatusCommand request, CancellationToken ct)
    {
        var studentTrip = await _unitOfWork.StudentTrips
            .GetByStudentAndTripAsync(request.StudentId, request.TripId, ct);

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
        return Result.Success();
    }
}
