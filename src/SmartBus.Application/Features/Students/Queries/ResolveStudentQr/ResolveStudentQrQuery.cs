using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Queries.ResolveStudentQr;

/// <summary>
/// Resolve a student-QR token to its linked student, side-effect free.
/// Used by the assistant trip-setup screen to add a student to the pending
/// roster before the trip itself has been created. The full
/// scan-and-attach flow lives in <see cref="Commands.ScanQr.ScanStudentQrCommand"/>
/// — that one requires a tripId and writes attendance / boarding state.
/// </summary>
public record ResolveStudentQrQuery(string Token)
    : IRequest<Result<ResolveStudentQrResponse>>;

public record ResolveStudentQrResponse(
    string StudentId,
    string FullName,
    string? FullNameEn,
    string Grade);
