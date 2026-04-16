using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;

namespace SmartBus.Application.Features.Buses.Queries.GetBusById;

public record GetBusByIdQuery(Guid BusId) : IRequest<Result<BusDto>>;
