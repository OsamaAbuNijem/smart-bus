using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Parents.Queries.GetStudentInfo;

/// <summary>
/// Detail view for one of the parent's children, sized for the Student Info
/// screen (Template/student-info (1).html).
/// </summary>
public record GetStudentInfoQuery(Guid ParentId, Guid StudentId)
    : IRequest<Result<StudentInfoDto>>;

public record StudentInfoDto(
    Guid Id,
    string FullName,
    string? FullNameEn,
    string NationalNumber,
    string Grade,
    string? Class,
    DateOnly? DateOfBirth,
    string? SchoolName,
    string? SchoolAddress,
    string HomeAddress,
    string? HomeArea,
    string? HomeStreet,
    string? Notes,
    string? RouteName,
    string? PickupStopName,
    IReadOnlyList<string> Allergies,
    StudentContactDto? Parent);

public record StudentContactDto(
    Guid Id,
    string Name,
    string PhoneNumber,
    string? Relation,
    string? Address);
