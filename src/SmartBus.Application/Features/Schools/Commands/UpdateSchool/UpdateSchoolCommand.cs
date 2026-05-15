using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Schools.Commands.UpdateSchool;

public record UpdateSchoolCommand(
    Guid SchoolId,
    string Name,
    string City,
    string ContactEmail,
    string PhoneNumber,
    string AdminEmail,
    string? Notes,
    double? Latitude = null,
    double? Longitude = null
) : IRequest<Result>;
