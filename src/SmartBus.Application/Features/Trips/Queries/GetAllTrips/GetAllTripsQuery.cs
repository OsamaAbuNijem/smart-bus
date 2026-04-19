using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Queries.GetAllTrips;

public record GetAllTripsQuery(
    int PageNumber = 1,
    int PageSize = 10,
    string? PersonName = null,   // matches driver OR assistant name (contains, case-insensitive)
    DateOnly? Date = null,
    string? Status = null        // "Scheduled" | "InProgress" | "Completed" | "Cancelled" | "Delayed"
) : IRequest<PagedResult<TripDto>>;

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
