using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Commands.UpdateDriver;

public record UpdateDriverCommand(
    Guid DriverId,
    string FullName,
    string PhoneNumber,
    string LicenseNumber,
    bool IsActive
) : IRequest<Result>;
