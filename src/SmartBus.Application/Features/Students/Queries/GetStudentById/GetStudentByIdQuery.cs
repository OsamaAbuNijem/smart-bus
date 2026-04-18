using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Queries.GetStudentById;

public record GetStudentByIdQuery(Guid StudentId) : IRequest<Result<StudentDetailDto>>;

public record StudentDetailDto(
    Guid Id,
    string FullName,
    string? FullNameEn,
    string Grade,
    string? Class,
    DateOnly? DateOfBirth,
    string? Address,
    string ParentName,
    string? ParentNameEn,
    string ParentPhone,
    string? RouteName,
    double? Latitude,
    double? Longitude,
    string? HomeArea,
    string? HomeStreet,
    string? HomeBuildingNumber,
    IReadOnlyList<string> Allergies,
    IReadOnlyList<EmergencyContactDto> EmergencyContacts,
    DateTime CreatedAt
);

public record EmergencyContactDto(Guid Id, string Name, string PhoneNumber, string? Relation);
