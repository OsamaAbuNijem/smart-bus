using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.StudentTrips.Commands.UpdateBoardingStatus;

public class UpdateBoardingStatusCommandHandler : IRequestHandler<UpdateBoardingStatusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateBoardingStatusCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(UpdateBoardingStatusCommand request, CancellationToken cancellationToken)
    {
        var studentTrip = await _unitOfWork.StudentTrips.GetByStudentAndTripAsync(request.StudentId, request.TripId, cancellationToken);

        if (studentTrip is null)
        {
            studentTrip = new StudentTrip
            {
                StudentId = request.StudentId,
                TripId = request.TripId,
                BoardingStatus = request.Status,
                BoardingTime = request.BoardingTime ?? (request.Status == Domain.Enums.BoardingStatus.Boarded ? DateTime.UtcNow : null)
            };
            await _unitOfWork.StudentTrips.AddAsync(studentTrip, cancellationToken);
        }
        else
        {
            studentTrip.BoardingStatus = request.Status;
            if (request.BoardingTime.HasValue) studentTrip.BoardingTime = request.BoardingTime;
            await _unitOfWork.StudentTrips.UpdateAsync(studentTrip);
        }

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
