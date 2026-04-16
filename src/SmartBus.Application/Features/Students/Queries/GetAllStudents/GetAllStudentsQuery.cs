using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Queries.GetAllStudents;

public record GetAllStudentsQuery(int PageNumber = 1, int PageSize = 10, Guid? RouteId = null) : IRequest<PagedResult<StudentDto>>;

public record StudentDto(
    Guid Id,
    string FullName,
    string Grade,
    string? Class,
    string ParentName,
    string ParentPhone,
    string? RouteName,
    DateTime CreatedAt
);
