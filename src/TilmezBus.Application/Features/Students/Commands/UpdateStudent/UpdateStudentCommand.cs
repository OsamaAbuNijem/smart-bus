using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Commands.UpdateStudent;

public record UpdateStudentCommand(
    Guid StudentId,
    string FullName,
    string? FullNameEn,
    string NationalNumber,
    string Grade,
    string? Class,
    DateOnly? DateOfBirth,
    string? Address,
    string ParentName,
    string ParentPhone,
    Guid? RouteId,
    Guid? PickupStopId,
    double? Latitude,
    double? Longitude,
    string? HomeArea,
    string? HomeStreet,
    string? HomeBuildingNumber
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CacheKeysToInvalidate      => new[] { $"student:{StudentId}" };
    public IEnumerable<string> CachePatternsToInvalidate  => new[] { "students:page:*" };
}
