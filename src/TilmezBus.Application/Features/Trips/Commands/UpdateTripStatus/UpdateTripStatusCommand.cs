using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Commands.UpdateTripStatus;

public record UpdateTripStatusCommand(Guid TripId, TripStatus NewStatus, string? Notes = null)
    : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "trips:page:*" };
}
