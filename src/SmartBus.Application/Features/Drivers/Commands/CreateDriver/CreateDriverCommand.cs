using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Drivers.Commands.CreateDriver;

public record CreateDriverCommand(
    string FullName,
    string? FullNameEn,
    string PhoneNumber,
    string LicenseNumber,
    bool IsActive = true,
    DriverType DriverType = DriverType.Driver
) : IRequest<Result<Guid>>;
