using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Trips.Commands.DeleteTrip;

public class DeleteTripCommandHandler : IRequestHandler<DeleteTripCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public DeleteTripCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(DeleteTripCommand request, CancellationToken cancellationToken)
    {
        var trip = await _unitOfWork.Trips.GetByIdAsync(request.TripId, cancellationToken);
        if (trip is null) return Result.Failure("Trip not found.");

        // Driver/Assistant callers may only cancel Scheduled trips (they
        // can't wipe a live or completed one). Admin overrides that gate.
        if (!request.AdminOverride && trip.Status != TilmezBus.Domain.Enums.TripStatus.Scheduled)
            return Result.Failure("Only scheduled trips can be deleted.");

        await _unitOfWork.Trips.DeleteAsync(trip);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
