using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Schools.Queries.GetAllSchools;

public record GetAllSchoolsQuery(int PageNumber = 1, int PageSize = 10) : IRequest<PagedResult<SchoolDto>>;

public record SchoolDto(
    Guid Id,
    string Name,
    string City,
    string ContactEmail,
    string PhoneNumber,
    string AdminEmail,
    string? Notes,
    DateTime CreatedAt
);
