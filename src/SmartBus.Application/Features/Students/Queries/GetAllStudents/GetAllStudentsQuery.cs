using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Queries.GetAllStudents;

public record GetAllStudentsQuery(
    int PageNumber = 1,
    int PageSize = 10,
    Guid? RouteId = null,
    string? Name = null,
    string? Grade = null,
    string? HomeArea = null
) : IRequest<PagedResult<StudentDto>>, ICacheableQuery
{
    public string CacheKey => $"students:page:{PageNumber}:size:{PageSize}:route:{RouteId?.ToString() ?? "_"}:name:{Name ?? "_"}:grade:{Grade ?? "_"}:area:{HomeArea ?? "_"}";
    public TimeSpan? CacheExpiry => TimeSpan.FromMinutes(2);
}

public record StudentDto(
    Guid Id,
    string FullName,
    string? FullNameEn,
    string Grade,
    string? Class,
    string ParentName,
    string? ParentNameEn,
    string ParentPhone,
    string? RouteName,
    double? Latitude,
    double? Longitude,
    string? HomeArea,
    string? HomeStreet,
    string? HomeBuildingNumber,
    DateTime CreatedAt
);
