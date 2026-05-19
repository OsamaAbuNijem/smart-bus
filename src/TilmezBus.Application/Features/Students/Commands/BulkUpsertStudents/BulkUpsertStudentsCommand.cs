using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Commands.BulkUpsertStudents;

/// <summary>
/// One row coming from the Excel import. Only the fields present in the
/// reduced template are accepted — address/GPS are intentionally absent and
/// existing values are preserved for already-known students.
/// </summary>
public record BulkUpsertStudentRow(
    string FullName,
    string? FullNameEn,
    string NationalNumber,
    string Grade,
    string ParentName,
    string ParentPhone
);

public record BulkUpsertStudentsResult(
    int Created,
    int Updated,
    int Failed,
    IReadOnlyList<string> Errors
);

public record BulkUpsertStudentsCommand(
    string SchoolId,
    IReadOnlyList<BulkUpsertStudentRow> Rows
) : IRequest<Result<BulkUpsertStudentsResult>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "students:page:*" };
}
