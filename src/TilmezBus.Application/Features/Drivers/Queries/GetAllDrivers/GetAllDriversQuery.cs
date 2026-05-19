using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Drivers.Queries.GetAllDrivers;

public record GetAllDriversQuery(
    int PageNumber = 1,
    int PageSize = 10,
    DriverType? DriverType = null,
    Guid?       SchoolId   = null
) : IRequest<PagedResult<DriverDto>>, ICacheableQuery
{
    public string CacheKey =>
        $"drivers:page:{PageNumber}:size:{PageSize}:type:{DriverType?.ToString() ?? "all"}:school:{SchoolId?.ToString() ?? ""}";
    public TimeSpan? CacheExpiry => TimeSpan.FromMinutes(2);
}

public record DriverDto(
    Guid Id,
    string FullName,
    string? FullNameEn,
    string PhoneNumber,
    bool IsActive,
    DriverType DriverType,
    DateTime CreatedAt
);
