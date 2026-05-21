using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Queries.GetStudentById;

public record GetStudentByIdQuery(Guid StudentId) : IRequest<Result<StudentDetailDto>>, ICacheableQuery
{
    // v2 — DTO shape changed (added NationalNumber, dropped ParentNameEn).
    // The version prefix orphans any pre-change Redis entries.
    public string CacheKey => $"student:v2:{StudentId}";
    public TimeSpan? CacheExpiry => TimeSpan.FromMinutes(5);
}

public record StudentDetailDto(
    Guid Id,
    string FullName,
    string? FullNameEn,
    string NationalNumber,
    string Grade,
    string? Class,
    DateOnly? DateOfBirth,
    string? Address,
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
