using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Attendance.Queries.GetAttendanceByTrip;

public record GetAttendanceByTripQuery(Guid TripId) : IRequest<Result<IReadOnlyList<TripAttendanceDto>>>;

public record TripAttendanceDto(Guid StudentId, string StudentName, string Grade, AttendanceStatus Status, DateTime? BoardingTime);
