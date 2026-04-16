using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Commands.DeleteDriver;

public record DeleteDriverCommand(Guid DriverId) : IRequest<Result>;
