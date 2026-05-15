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
    string? HomeArea = null,
    Guid? SchoolId = null
) : IRequest<PagedResult<StudentDto>>, ICacheableQuery
{
    // School scope is part of the cache key so each tenant's pages don't bleed
    // into each other.
    public string CacheKey => $"students:page:{PageNumber}:size:{PageSize}:route:{RouteId?.ToString() ?? "_"}:name:{Name ?? "_"}:grade:{Grade ?? "_"}:area:{HomeArea ?? "_"}:school:{SchoolId?.ToString() ?? "_"}";
    public TimeSpan? CacheExpiry => TimeSpan.FromMinutes(2);
}

public record StudentDto(
    Guid Id,
    string FullName,
    string? FullNameEn,
    string NationalNumber,
    string Grade,
    string? Class,
    string ParentName,
    string ParentPhone,
    string? RouteName,
    double? Latitude,
    double? Longitude,
    string? HomeArea,
    string? HomeStreet,
    string? HomeBuildingNumber,
    DateTime CreatedAt
);
