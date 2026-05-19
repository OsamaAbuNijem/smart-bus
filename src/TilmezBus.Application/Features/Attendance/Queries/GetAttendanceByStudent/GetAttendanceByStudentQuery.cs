using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Attendance.Queries.GetAttendanceByStudent;

public record GetAttendanceByStudentQuery(Guid StudentId, DateOnly? From = null, DateOnly? To = null) : IRequest<Result<AttendanceSummaryDto>>;

public record AttendanceSummaryDto(
    Guid StudentId,
    string StudentName,
    int TotalDays,
    int PresentDays,
    int LateDays,
    int AbsentDays,
    double AttendanceRate,
    IReadOnlyList<AttendanceRecordDto> Records
);

public record AttendanceRecordDto(Guid Id, DateOnly Date, AttendanceStatus Status, DateTime? BoardingTime, string TripName);
