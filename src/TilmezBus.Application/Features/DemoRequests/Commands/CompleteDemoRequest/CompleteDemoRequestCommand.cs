using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.DemoRequests.Commands.CompleteDemoRequest;

/// <summary>
/// SuperAdmin marks a demo request as completed once they've reached out
/// to the school. Idempotent: re-running on an already-completed request
/// is a no-op (still succeeds).
/// </summary>
public record CompleteDemoRequestCommand(Guid Id, string? CompletedByUserId) : IRequest<Result>;
