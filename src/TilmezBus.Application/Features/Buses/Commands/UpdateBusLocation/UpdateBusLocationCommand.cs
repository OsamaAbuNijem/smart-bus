using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Buses.Commands.UpdateBusLocation;

public record UpdateBusLocationCommand(
    Guid BusId,
    double Latitude,
    double Longitude,
    double? Speed,
    double? Heading
) : IRequest<Result>;
