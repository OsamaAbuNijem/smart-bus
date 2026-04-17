using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.DeleteTrip;

public class DeleteTripCommandHandler : IRequestHandler<DeleteTripCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public DeleteTripCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(DeleteTripCommand request, CancellationToken cancellationToken)
    {
        var trip = await _unitOfWork.Trips.GetByIdAsync(request.TripId, cancellationToken);
        if (trip is null) return Result.Failure("Trip not found.");

        await _unitOfWork.Trips.DeleteAsync(trip);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
