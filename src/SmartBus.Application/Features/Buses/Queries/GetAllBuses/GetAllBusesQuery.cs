using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Queries.GetAllBuses;

public record GetAllBusesQuery(
    int PageNumber = 1,
    int PageSize = 10,
    string? PlateNumber = null,
    string? PersonName  = null
) : IRequest<PagedResult<BusDto>>, ICacheableQuery
{
    public string CacheKey =>
        $"buses:page:{PageNumber}:size:{PageSize}:plate:{PlateNumber ?? ""}:person:{PersonName ?? ""}";
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
