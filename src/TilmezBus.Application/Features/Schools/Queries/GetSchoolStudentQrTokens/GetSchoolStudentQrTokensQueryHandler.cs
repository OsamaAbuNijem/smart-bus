using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Schools.Queries.GetSchoolStudentQrTokens;

public class GetSchoolStudentQrTokensQueryHandler
    : IRequestHandler<GetSchoolStudentQrTokensQuery, Result<SchoolStudentQrTokensDto>>
{
    private readonly IApplicationDbContext _context;

    public GetSchoolStudentQrTokensQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<SchoolStudentQrTokensDto>> Handle(
        GetSchoolStudentQrTokensQuery request, CancellationToken ct)
    {
        var school = await _context.Schools
            .Where(s => s.Id == request.SchoolId)
            .Select(s => new { s.Id, s.Name })
            .FirstOrDefaultAsync(ct);
        if (school is null) return Result<SchoolStudentQrTokensDto>.Failure("School not found.");

        var rows = await _context.StudentQrTokens
            .Where(t => t.SchoolId == request.SchoolId)
            .OrderBy(t => t.IsRegistered).ThenBy(t => t.CreatedAt)
            .Select(t => new StudentQrTokenDto(
                t.Id,
                t.Token,
                t.IsRegistered,
                t.RegisteredAt,
                t.StudentId,
                t.Student != null ? t.Student.FullName : null,
                t.Student != null ? t.Student.Grade    : null,
                t.CreatedAt))
            .ToListAsync(ct);

        var registered = rows.Count(r => r.IsRegistered);
        return Result<SchoolStudentQrTokensDto>.Success(
            new SchoolStudentQrTokensDto(school.Id, school.Name, rows.Count, registered, rows));
    }
}
