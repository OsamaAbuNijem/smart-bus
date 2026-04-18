using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.UpdateBus;

public record UpdateBusCommand(
    Guid BusId,
    string PlateNumber,
    int Capacity,
    string Status,
    Guid? DriverId,
    Guid? AssistantDriverId,
    IEnumerable<Guid> StudentIds
) : IRequest<Result>;
