using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Commands.DeleteDriver;

public record DeleteDriverCommand(Guid DriverId) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"driver:{DriverId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "drivers:page:*" };
}
