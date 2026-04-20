using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;

public record GetAllDriversQuery(
    int PageNumber = 1,
    int PageSize = 10,
    DriverType? DriverType = null
) : IRequest<PagedResult<DriverDto>>, ICacheableQuery
{
    public string CacheKey => $"drivers:page:{PageNumber}:size:{PageSize}:type:{DriverType?.ToString() ?? "all"}";
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
