using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.DeleteBus;

public record DeleteBusCommand(Guid BusId) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"bus:{BusId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "buses:page:*" };
}
