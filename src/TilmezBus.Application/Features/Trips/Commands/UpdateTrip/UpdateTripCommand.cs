using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Commands.UpdateTrip;

public record UpdateTripCommand(
    Guid TripId,
    string Name,
    TripType Type,
    Guid BusId,
    Guid? RouteId,
    DateTime ScheduledDeparture,
    byte RepeatDays,
    string? Notes
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "trips:page:*" };
}
