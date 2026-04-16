using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Queries.GetStudentById;

public record GetStudentByIdQuery(Guid StudentId) : IRequest<Result<StudentDetailDto>>;

public record StudentDetailDto(
    Guid Id,
    string FullName,
    string Grade,
    string? Class,
    DateOnly? DateOfBirth,
    string? Address,
    string ParentName,
    string ParentPhone,
    string? RouteName,
    IReadOnlyList<string> Allergies,
    IReadOnlyList<EmergencyContactDto> EmergencyContacts,
    DateTime CreatedAt
);

public record EmergencyContactDto(Guid Id, string Name, string PhoneNumber, string? Relation);
