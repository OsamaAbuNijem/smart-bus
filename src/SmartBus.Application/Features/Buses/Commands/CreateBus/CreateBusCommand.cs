using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.CreateBus;

public record CreateBusCommand(
    string PlateNumber,
    string Model,
    int Capacity,
    Guid? DriverId
) : IRequest<Result<Guid>>;
