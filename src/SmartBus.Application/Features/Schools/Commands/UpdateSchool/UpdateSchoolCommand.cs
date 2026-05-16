using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Schools.Commands.UpdateSchool;

public record UpdateSchoolCommand(
    Guid SchoolId,
    string Name,
    string City,
    string PhoneNumber,
    string AdminEmail,
    string? ContactName = null,
    double? Latitude    = null,
    double? Longitude   = null,
    string? LogoUrl     = null
) : IRequest<Result>;
