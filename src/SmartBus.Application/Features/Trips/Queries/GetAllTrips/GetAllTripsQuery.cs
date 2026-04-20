using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Queries.GetAllTrips;

public record GetAllTripsQuery(
    int PageNumber = 1,
    int PageSize = 10,
    string? PersonName = null,
    DateOnly? Date = null,
    string? Status = null
) : IRequest<PagedResult<TripDto>>, ICacheableQuery
{
    public string CacheKey => $"trips:page:{PageNumber}:size:{PageSize}:p:{PersonName ?? "_"}:d:{Date?.ToString("yyyy-MM-dd") ?? "_"}:s:{Status ?? "_"}";
    // Trips change state often (start/complete); keep TTL short.
    public TimeSpan? CacheExpiry => TimeSpan.FromSeconds(30);
}

public record TripDto(
    Guid Id,
    Guid BusId,
    string BusPlateNumber,
    string? RouteName,
    string TripType,
    DateTime ScheduledDeparture,
    DateTime? ActualDeparture,
    DateTime? ActualArrival,
    string Status,
    byte RepeatDays,
    string? DriverName,
    string? AssistantDriverName
);
