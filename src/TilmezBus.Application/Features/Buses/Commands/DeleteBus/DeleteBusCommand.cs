using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Buses.Commands.DeleteBus;

public record DeleteBusCommand(Guid BusId) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"bus:{BusId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "buses:page:*" };
}
