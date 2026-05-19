using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Routes.Queries.GetRouteById;

public record GetRouteByIdQuery(Guid RouteId) : IRequest<Result<RouteDetailDto>>;

public record RouteDetailDto(
    Guid Id, string Name, string Description,
    double StartLatitude, double StartLongitude,
    double EndLatitude, double EndLongitude,
    IReadOnlyList<StopDto> Stops,
    DateTime CreatedAt
);

public record StopDto(Guid Id, string Name, double Latitude, double Longitude, int Order);
