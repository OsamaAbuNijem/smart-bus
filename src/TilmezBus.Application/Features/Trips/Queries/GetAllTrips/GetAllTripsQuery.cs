using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Trips.Queries.GetAllTrips;

public record GetAllTripsQuery(
    int PageNumber = 1,
    int PageSize = 10,
    string? PersonName = null,
    DateOnly? Date = null,
    string? Status = null,
    string? BusPlateNumber = null
) : IRequest<PagedResult<TripDto>>, ICacheableQuery
{
    public string CacheKey => $"trips:page:{PageNumber}:size:{PageSize}:p:{PersonName ?? "_"}:d:{Date?.ToString("yyyy-MM-dd") ?? "_"}:s:{Status ?? "_"}:b:{BusPlateNumber ?? "_"}";
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
