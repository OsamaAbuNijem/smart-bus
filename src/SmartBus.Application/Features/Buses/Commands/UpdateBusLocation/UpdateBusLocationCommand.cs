using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.UpdateBusLocation;

public record UpdateBusLocationCommand(
    Guid BusId,
    double Latitude,
    double Longitude,
    double? Speed,
    double? Heading
) : IRequest<Result>;
