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
    Guid? SchoolId = null,
    // "ar" → match/order by FullName only; "en" → match/order by FullNameEn
    // only. null (default) keeps the original behavior of matching both,
    // which the admin grid still relies on.
    string? Lang = null
) : IRequest<PagedResult<StudentDto>>, ICacheableQuery
{
    // School + lang are part of the cache key so each tenant / locale's
    // pages don't bleed into each other.
    public string CacheKey => $"students:page:{PageNumber}:size:{PageSize}:route:{RouteId?.ToString() ?? "_"}:name:{Name ?? "_"}:grade:{Grade ?? "_"}:area:{HomeArea ?? "_"}:school:{SchoolId?.ToString() ?? "_"}:lang:{Lang ?? "_"}";
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
