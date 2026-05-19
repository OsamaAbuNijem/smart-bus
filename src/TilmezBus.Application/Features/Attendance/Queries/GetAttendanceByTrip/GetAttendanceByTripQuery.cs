using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Attendance.Queries.GetAttendanceByTrip;

public record GetAttendanceByTripQuery(Guid TripId) : IRequest<Result<IReadOnlyList<TripAttendanceDto>>>;

public record TripAttendanceDto(Guid StudentId, string StudentName, string Grade, AttendanceStatus Status, DateTime? BoardingTime);
