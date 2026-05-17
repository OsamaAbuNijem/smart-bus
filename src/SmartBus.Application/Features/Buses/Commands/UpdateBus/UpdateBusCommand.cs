using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.UpdateBus;

/// <summary>
/// Partial-update command: every non-id field is nullable so the admin grid
/// can flip a single field (status toggle, inline rename) without re-sending
/// the whole bus. Fields left null preserve the existing value.
/// </summary>
public record UpdateBusCommand(
    Guid BusId,
    string? PlateNumber = null,
    int? Capacity = null,
    string? Status = null
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"bus:{BusId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "buses:page:*" };
}
