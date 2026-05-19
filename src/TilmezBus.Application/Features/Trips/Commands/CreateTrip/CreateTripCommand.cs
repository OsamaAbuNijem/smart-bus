using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Trips.Commands.CreateTrip;

public record CreateTripCommand(
    Guid BusId,
    Guid RouteId,
    DateTime ScheduledDeparture
) : IRequest<Result<Guid>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "trips:page:*" };
}
