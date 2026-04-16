using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Attendance.Commands.RecordAttendance;

public record RecordAttendanceCommand(
    Guid StudentId,
    Guid TripId,
    DateOnly Date,
    AttendanceStatus Status,
    DateTime? BoardingTime,
    DateTime? DropoffTime
) : IRequest<Result<Guid>>;
