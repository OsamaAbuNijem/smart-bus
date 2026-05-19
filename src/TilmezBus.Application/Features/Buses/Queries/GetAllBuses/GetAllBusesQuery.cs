using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Buses.Queries.GetAllBuses;

public record GetAllBusesQuery(
    int PageNumber = 1,
    int PageSize = 10,
    string? PlateNumber = null,
    string? PersonName  = null,
    Guid?   SchoolId    = null
) : IRequest<PagedResult<BusDto>>, ICacheableQuery
{
    // Cache key includes the school scope so two admins on different schools
    // don't share a result set.
    public string CacheKey =>
        $"buses:page:{PageNumber}:size:{PageSize}:plate:{PlateNumber ?? ""}:person:{PersonName ?? ""}:school:{SchoolId?.ToString() ?? ""}";
    public TimeSpan? CacheExpiry => TimeSpan.FromMinutes(2);
}

public record BusDto(
    Guid Id,
    string PlateNumber,
    int Capacity,
    string Status,
    string? DriverName,
    string? AssistantDriverName,
    int StudentCount,
    IReadOnlyList<Guid> StudentIds,
    double? LastLatitude,
    double? LastLongitude,
    DateTime CreatedAt,
    bool IsScheduleComplete,
    string? QrToken
);
