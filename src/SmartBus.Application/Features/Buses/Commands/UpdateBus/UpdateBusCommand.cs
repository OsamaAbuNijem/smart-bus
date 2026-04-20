using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.UpdateBus;

public record UpdateBusCommand(
    Guid BusId,
    string PlateNumber,
    int Capacity,
    string Status,
    Guid? DriverId,
    Guid? AssistantDriverId,
    IEnumerable<Guid> StudentIds
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"bus:{BusId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "buses:page:*" };
}
