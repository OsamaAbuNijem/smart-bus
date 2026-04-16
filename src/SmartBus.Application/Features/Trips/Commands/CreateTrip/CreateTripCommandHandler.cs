using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Trips.Commands.CreateTrip;

public class CreateTripCommandHandler : IRequestHandler<CreateTripCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateTripCommandHandler(IUnitOfWork unitOfWork)
        => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(CreateTripCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result<Guid>.Failure("Bus not found.");

        var route = await _unitOfWork.Routes.GetByIdAsync(request.RouteId, cancellationToken);
        if (route is null) return Result<Guid>.Failure("Route not found.");

        var trip = new Trip
        {
            BusId = request.BusId,
            RouteId = request.RouteId,
            ScheduledDeparture = request.ScheduledDeparture
        };

        await _unitOfWork.Trips.AddAsync(trip, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<Guid>.Success(trip.Id);
    }
}
