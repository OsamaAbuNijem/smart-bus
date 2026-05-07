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
                    ?? (request.Status == BoardingStatus.Boarded ? DateTime.UtcNow : null)
            };
            await _unitOfWork.StudentTrips.AddAsync(studentTrip, ct);
        }
        else
        {
            studentTrip.BoardingStatus = request.Status;
            if (request.BoardingTime.HasValue) studentTrip.BoardingTime = request.BoardingTime;
            await _unitOfWork.StudentTrips.UpdateAsync(studentTrip);
        }

        // On Morning pickups we treat the boarding GPS as the student's home
        // pickup point. Skip Return trips — that GPS is the school, not home.
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
                if (student is not null)
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
