using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Queries.GetStudentQrToken;

/// <summary>
/// Admin-only — returns the registered QR token currently bound to
/// [StudentId]. Used by the admin students grid's "View QR" action so
/// the Web can render / print a QR image. Null if no token is bound
/// yet (e.g. legacy student row before the auto-mint rollout).
/// </summary>
public record GetStudentQrTokenQuery(Guid StudentId)
    : IRequest<Result<string?>>;
