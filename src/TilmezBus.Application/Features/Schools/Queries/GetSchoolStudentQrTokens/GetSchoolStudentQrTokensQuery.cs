using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Schools.Queries.GetSchoolStudentQrTokens;

/// <summary>SuperAdmin: list every student-registration QR token for a school.</summary>
public record GetSchoolStudentQrTokensQuery(Guid SchoolId)
    : IRequest<Result<SchoolStudentQrTokensDto>>;

public record SchoolStudentQrTokensDto(
    Guid SchoolId,
    string SchoolName,
    int TotalCount,
    int RegisteredCount,
    IReadOnlyList<StudentQrTokenDto> Tokens
);

public record StudentQrTokenDto(
    Guid Id,
    string Token,
    bool IsRegistered,
    DateTime? RegisteredAt,
    Guid? StudentId,
    string? StudentName,
    string? StudentGrade,
    DateTime CreatedAt
);
