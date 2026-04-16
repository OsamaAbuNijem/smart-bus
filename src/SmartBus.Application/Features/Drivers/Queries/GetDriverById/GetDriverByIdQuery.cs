using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;

namespace SmartBus.Application.Features.Drivers.Queries.GetDriverById;

public record GetDriverByIdQuery(Guid DriverId) : IRequest<Result<DriverDto>>;
