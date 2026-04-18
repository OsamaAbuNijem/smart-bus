using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.DeleteBus;

public record DeleteBusCommand(Guid BusId) : IRequest<Result>;
