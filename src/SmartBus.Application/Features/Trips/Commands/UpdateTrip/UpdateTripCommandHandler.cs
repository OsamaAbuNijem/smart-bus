using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.UpdateTrip;

public class UpdateTripCommandHandler : IRequestHandler<UpdateTripCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateTripCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(UpdateTripCommand request, CancellationToken cancellationToken)
    {
        var trip = await _unitOfWork.Trips.GetByIdAsync(request.TripId, cancellationToken);
        if (trip is null) return Result.Failure("Trip not found.");

        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result.Failure("Bus not found.");

        trip.Name = request.Name;
        trip.Type = request.Type;
        trip.BusId = request.BusId;
        trip.RouteId = request.RouteId;
        trip.ScheduledDeparture = request.ScheduledDeparture;
        trip.RepeatDays = request.RepeatDays;
        trip.Notes = request.Notes;

        await _unitOfWork.Trips.UpdateAsync(trip);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
