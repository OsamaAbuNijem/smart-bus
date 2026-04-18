using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;

namespace SmartBus.Application.Features.Buses.Queries.GetAllBuses;

public record GetAllBusesQuery(int PageNumber = 1, int PageSize = 10) : IRequest<PagedResult<BusDto>>;

public record BusDto(
    Guid Id,
    string PlateNumber,
    int Capacity,
    string Status,
    Guid? DriverId,
    string? DriverName,
    Guid? AssistantDriverId,
    string? AssistantDriverName,
    int StudentCount,
    IReadOnlyList<Guid> StudentIds,
    double? LastLatitude,
    double? LastLongitude,
    DateTime CreatedAt
);
