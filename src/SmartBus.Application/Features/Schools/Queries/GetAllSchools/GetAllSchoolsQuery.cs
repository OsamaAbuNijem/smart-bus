using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Schools.Queries.GetAllSchools;

public record GetAllSchoolsQuery(int PageNumber = 1, int PageSize = 10) : IRequest<PagedResult<SchoolDto>>;

public record SchoolDto(
    Guid Id,
    string Name,
    string City,
    string ContactEmail,
    string PhoneNumber,
    string AdminEmail,
    PlanType Plan,
    int MaxBuses,
    bool IsActive,
    string? Notes,
    DateTime CreatedAt
);
