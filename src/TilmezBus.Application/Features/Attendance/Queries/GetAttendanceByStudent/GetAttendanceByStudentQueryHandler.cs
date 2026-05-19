using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Attendance.Queries.GetAttendanceByStudent;

public class GetAttendanceByStudentQueryHandler : IRequestHandler<GetAttendanceByStudentQuery, Result<AttendanceSummaryDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAttendanceByStudentQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<AttendanceSummaryDto>> Handle(GetAttendanceByStudentQuery request, CancellationToken cancellationToken)
    {
        var student = await _context.Students
            .Where(s => s.Id == request.StudentId && !s.IsDeleted)
            .FirstOrDefaultAsync(cancellationToken);

        if (student is null) return Result<AttendanceSummaryDto>.Failure("Student not found.");

        IQueryable<TilmezBus.Domain.Entities.Attendance> query = _context.Attendances
            .Where(a => a.StudentId == request.StudentId && !a.IsDeleted)
            .Include(a => a.Trip);

        if (request.From.HasValue) query = query.Where(a => a.Date >= request.From.Value);
        if (request.To.HasValue) query = query.Where(a => a.Date <= request.To.Value);

        var records = await query.OrderByDescending(a => a.Date).ToListAsync(cancellationToken);

        var total = records.Count;
        var present = records.Count(r => r.Status == AttendanceStatus.Present);
        var late = records.Count(r => r.Status == AttendanceStatus.Late);
        var absent = records.Count(r => r.Status == AttendanceStatus.Absent);
        var rate = total > 0 ? Math.Round((present + late) * 100.0 / total, 1) : 0;

        var dto = new AttendanceSummaryDto(
            student.Id, student.FullName, total, present, late, absent, rate,
            records.Select(r => new AttendanceRecordDto(r.Id, r.Date, r.Status, r.BoardingTime, r.Trip.Name)).ToList());

        return Result<AttendanceSummaryDto>.Success(dto);
    }
}
