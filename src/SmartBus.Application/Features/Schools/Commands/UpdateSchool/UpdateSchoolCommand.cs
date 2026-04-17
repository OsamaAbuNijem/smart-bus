using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Schools.Commands.UpdateSchool;

public record UpdateSchoolCommand(
    Guid SchoolId,
    string Name,
    string City,
    string ContactEmail,
    string PhoneNumber,
    string AdminEmail,
    PlanType Plan,
    int MaxBuses,
    bool IsActive,
    string? Notes
) : IRequest<Result>;
