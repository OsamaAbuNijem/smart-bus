using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.DeleteTrip;

public record DeleteTripCommand(
    Guid TripId,
    // True when the caller is an Admin and can delete trips in any status.
    // Driver/Assistant callers pass false → handler restricts to Scheduled
    // (they cannot wipe a live or completed trip).
    bool AdminOverride = false
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "trips:page:*" };
}
