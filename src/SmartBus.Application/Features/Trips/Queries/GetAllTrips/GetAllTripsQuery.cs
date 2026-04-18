using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Queries.GetAllTrips;

public record GetAllTripsQuery(int PageNumber = 1, int PageSize = 10) : IRequest<PagedResult<TripDto>>;

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
    byte RepeatDays
);
