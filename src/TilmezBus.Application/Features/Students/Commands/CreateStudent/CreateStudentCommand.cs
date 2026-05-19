using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Commands.CreateStudent;

public record CreateStudentCommand(
    string SchoolId,
    string FullName,
    string? FullNameEn,
    string NationalNumber,
    string Grade,
    string? Class,
    DateOnly? DateOfBirth,
    string? Address,
    string ParentName,
    string ParentPhone,
    Guid? ParentId,
    Guid? RouteId,
    Guid? PickupStopId,
    double? Latitude,
    double? Longitude,
    string? HomeArea,
    string? HomeStreet,
    string? HomeBuildingNumber
) : IRequest<Result<Guid>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "students:page:*" };
}
