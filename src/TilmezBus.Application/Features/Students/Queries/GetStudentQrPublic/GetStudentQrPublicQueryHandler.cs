using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Queries.GetStudentQrPublic;

public class GetStudentQrPublicQueryHandler
    : IRequestHandler<GetStudentQrPublicQuery, Result<PublicStudentQrDto>>
{
    private readonly IApplicationDbContext _context;

    public GetStudentQrPublicQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<PublicStudentQrDto>> Handle(
        GetStudentQrPublicQuery request, CancellationToken ct)
    {
        var token = (request.Token ?? string.Empty).Trim();
        if (token.Length == 0)
            return Result<PublicStudentQrDto>.Failure("QR token is required.");

        // Single round-trip: join token → student → parent + school. We
        // intentionally return a not-found result when the token isn't
        // linked yet so the public page can render a friendly "this QR
        // hasn't been registered" instead of leaking the bare token.
        var row = await _context.StudentQrTokens
            .Where(t => t.Token == token
                     && t.IsRegistered
                     && t.StudentId != null)
            .Join(_context.Students.Where(s => !s.IsDeleted),
                t => t.StudentId, s => s.Id, (t, s) => new { t, s })
            .Join(_context.Schools.Where(s => !s.IsDeleted),
                ts => Guid.Parse(ts.s.SchoolId), sc => sc.Id,
                (ts, sc) => new { ts.s, sc })
            .Select(x => new
            {
                Student = x.s,
                School  = x.sc,
                Parent  = x.s.Parent,
            })
            .FirstOrDefaultAsync(ct);

        if (row is null)
            return Result<PublicStudentQrDto>.Failure("QR not found or not registered.");

        return Result<PublicStudentQrDto>.Success(new PublicStudentQrDto(
            StudentName:   row.Student.FullName,
            StudentNameEn: row.Student.FullNameEn,
            Grade:         row.Student.Grade,
            ParentName:    row.Parent?.FullName,
            ParentPhone:   row.Parent?.PhoneNumber,
            SchoolName:    row.School.Name,
            SchoolPhone:   row.School.PhoneNumber,
            SchoolLogoUrl: row.School.LogoUrl,
            City:          row.School.City));
    }
}
