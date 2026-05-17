using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Drivers.Commands.UpdateDriver;

/// <summary>
/// Partial-update command: every non-id field is nullable so the admin grid
/// can flip a single field (name rename, phone, status toggle, type swap)
/// without re-sending the whole driver. Nulls preserve existing values.
/// </summary>
public record UpdateDriverCommand(
    Guid DriverId,
    string? FullName = null,
    string? FullNameEn = null,
    string? PhoneNumber = null,
    bool? IsActive = null,
    DriverType? DriverType = null
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"driver:{DriverId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "drivers:page:*" };
}
