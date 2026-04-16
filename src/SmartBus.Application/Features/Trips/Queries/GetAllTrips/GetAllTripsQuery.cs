using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Queries.GetAllTrips;

public record GetAllTripsQuery(int PageNumber = 1, int PageSize = 10) : IRequest<PagedResult<TripDto>>;

public record TripDto(
    Guid Id,
    string BusPlateNumber,
    string RouteName,
    DateTime ScheduledDeparture,
    DateTime? ActualDeparture,
    DateTime? ActualArrival,
    string Status
);
