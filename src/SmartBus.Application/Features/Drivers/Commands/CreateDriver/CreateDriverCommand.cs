using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Commands.CreateDriver;

public record CreateDriverCommand(
    string FullName,
    string PhoneNumber,
    string LicenseNumber
) : IRequest<Result<Guid>>;
