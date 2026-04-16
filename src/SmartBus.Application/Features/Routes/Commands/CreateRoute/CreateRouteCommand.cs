using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Routes.Commands.CreateRoute;

public record CreateRouteCommand(
    string Name,
    string? Description,
    double StartLatitude,
    double StartLongitude,
    double EndLatitude,
    double EndLongitude,
    IReadOnlyList<CreateStopRequest> Stops
) : IRequest<Result<Guid>>;

public record CreateStopRequest(string Name, double Latitude, double Longitude, int Order);
