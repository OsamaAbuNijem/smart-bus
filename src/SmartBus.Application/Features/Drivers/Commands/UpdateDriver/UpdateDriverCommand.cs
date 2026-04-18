using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Drivers.Commands.UpdateDriver;

public record UpdateDriverCommand(
    Guid DriverId,
    string FullName,
    string? FullNameEn,
    string PhoneNumber,
    string LicenseNumber,
    bool IsActive,
    DriverType DriverType
) : IRequest<Result>;
