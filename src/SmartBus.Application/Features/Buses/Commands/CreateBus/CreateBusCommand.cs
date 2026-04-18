using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.CreateBus;

public record CreateBusCommand(
    string PlateNumber,
    int Capacity,
    string Status,
    Guid? DriverId,
    Guid? AssistantDriverId,
    IEnumerable<Guid> StudentIds
) : IRequest<Result<Guid>>;
