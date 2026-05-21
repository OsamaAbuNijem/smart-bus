using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Trips.Commands.CreateTrip;

public class CreateTripCommandHandler : IRequestHandler<CreateTripCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateTripCommandHandler(IUnitOfWork unitOfWork)
        => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(CreateTripCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result<Guid>.Failure("Bus not found.");

        var trip = new Trip
        {
            BusId = request.BusId,
            ScheduledDeparture = request.ScheduledDeparture
        };

        await _unitOfWork.Trips.AddAsync(trip, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<Guid>.Success(trip.Id);
    }
}
