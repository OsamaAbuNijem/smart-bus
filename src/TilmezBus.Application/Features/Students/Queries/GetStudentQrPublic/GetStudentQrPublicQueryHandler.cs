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

        // Three small indexed lookups instead of one big EF Join. The
        // School lookup needs Guid.Parse on a `string` SchoolId column;
        // Npgsql can't translate that inside a server-side Join (it
        // silently returns no rows), so we resolve the StudentId first,
        // pull the Student + Parent in one trip, parse the SchoolId on
        // the client, then fetch the School.
        var studentId = await _context.StudentQrTokens
            .Where(t => t.Token == token
                     && t.IsRegistered
                     && t.StudentId != null)
            .Select(t => t.StudentId)
            .FirstOrDefaultAsync(ct);
        if (studentId is null)
            return Result<PublicStudentQrDto>.Failure(
                "QR not found or not registered.");

        var s = await _context.Students
            .Where(x => x.Id == studentId.Value && !x.IsDeleted)
            .Select(x => new
            {
                x.FullName,
                x.FullNameEn,
                x.Grade,
                x.SchoolId,
                ParentName  = x.Parent != null ? x.Parent.FullName    : null,
                ParentPhone = x.Parent != null ? x.Parent.PhoneNumber : null,
            })
            .FirstOrDefaultAsync(ct);
        if (s is null)
            return Result<PublicStudentQrDto>.Failure("Student not found.");

        if (!Guid.TryParse(s.SchoolId, out var schoolGuid))
            return Result<PublicStudentQrDto>.Failure(
                "Student's school is not configured correctly.");

        var sc = await _context.Schools
            .Where(x => x.Id == schoolGuid && !x.IsDeleted)
            .Select(x => new
            {
                x.Name,
                x.PhoneNumber,
                x.LogoUrl,
                x.City,
            })
            .FirstOrDefaultAsync(ct);
        if (sc is null)
            return Result<PublicStudentQrDto>.Failure("School not found.");

        return Result<PublicStudentQrDto>.Success(new PublicStudentQrDto(
            StudentName:   s.FullName,
            StudentNameEn: s.FullNameEn,
            Grade:         s.Grade,
            ParentName:    s.ParentName,
            ParentPhone:   s.ParentPhone,
            SchoolName:    sc.Name,
            SchoolPhone:   sc.PhoneNumber,
            SchoolLogoUrl: sc.LogoUrl,
            City:          sc.City));
    }
}
