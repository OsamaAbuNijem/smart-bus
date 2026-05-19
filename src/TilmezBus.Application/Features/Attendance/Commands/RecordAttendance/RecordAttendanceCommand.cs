using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Attendance.Commands.RecordAttendance;

public record RecordAttendanceCommand(
    Guid StudentId,
    Guid TripId,
    DateOnly Date,
    AttendanceStatus Status,
    DateTime? BoardingTime,
    DateTime? DropoffTime
) : IRequest<Result<Guid>>;
