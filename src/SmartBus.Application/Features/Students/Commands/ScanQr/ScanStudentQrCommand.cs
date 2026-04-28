using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Commands.ScanQr;

/// <summary>
/// Driver/assistant scans a student QR during a live trip. The handler flips
/// the StudentTrip state for that (trip, student) row:
///   • Waiting  → Boarded   (sets BoardingTime, writes Attendance=Present)
///   • Boarded  → Boarded   (sets DropoffTime — the second scan = "got off")
///   • Absent   → Absent    (no-op; clear via the admin UI if needed)
/// Idempotent on a per-state basis: re-scanning after dropoff is a no-op.
/// </summary>
public record ScanStudentQrCommand(string Token, Guid TripId)
    : IRequest<Result<ScanStudentQrResponse>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "trips:page:*", "students:page:*" };
}

public record ScanStudentQrResponse(
    Guid StudentId,
    string StudentName,
    Guid TripId,
    string Action,         // "Boarded" | "Dropoff" | "AlreadyDroppedOff"
    string BoardingStatus, // current StudentTrip.BoardingStatus
    DateTime? BoardingTime,
    DateTime? DropoffTime
);
