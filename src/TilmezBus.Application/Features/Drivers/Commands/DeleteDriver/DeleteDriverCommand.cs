using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Drivers.Commands.DeleteDriver;

public record DeleteDriverCommand(Guid DriverId) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"driver:{DriverId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "drivers:page:*" };
}
