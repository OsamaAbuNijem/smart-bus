using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.CreateTrip;

public record CreateTripCommand(
    Guid BusId,
    Guid RouteId,
    DateTime ScheduledDeparture
) : IRequest<Result<Guid>>;
