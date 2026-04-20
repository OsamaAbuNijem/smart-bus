using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.CreateTrip;

public record CreateTripCommand(
    Guid BusId,
    Guid RouteId,
    DateTime ScheduledDeparture
) : IRequest<Result<Guid>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "trips:page:*" };
}
