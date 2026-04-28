using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Queries.GetStudentRegistrationToken;

/// <summary>
/// Mobile-app prefetch right after the parent scans a student QR — lets the
/// app show "Register your child for &lt;school&gt;" before the form, and
/// short-circuits to a "this QR already belongs to &lt;name&gt;" view if the
/// token has already been bound to a student.
/// </summary>
public record GetStudentRegistrationTokenQuery(string Token)
    : IRequest<Result<StudentRegistrationTokenInfoDto>>;

public record StudentRegistrationTokenInfoDto(
    string Token,
    bool IsRegistered,
    Guid SchoolId,
    string SchoolName,
    string SchoolCity,
    Guid? StudentId,
    string? StudentName,
    string? StudentGrade
);
