using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Schools.Commands.CreateSchool;

public record CreateSchoolCommand(
    string Name,
    string City,
    string ContactEmail,
    string PhoneNumber,
    string AdminEmail,
    PlanType Plan,
    int MaxBuses,
    int MaxDrivers,
    int MaxAssistants,
    int MaxStudents,
    string? Notes,
    double? Latitude = null,
    double? Longitude = null,
    string AdminPassword = "Admin@123456"
) : IRequest<Result<Guid>>;
