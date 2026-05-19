using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.AbsenceRequests.Commands.ForceCancelAbsenceRequest;

/// <summary>
/// Crew-side cancel: allowed even while the matching trip is InProgress so
/// the assistant can revert an absent flag mid-trip when the student shows
/// up after all. Only blocked once the matching trip is already Completed.
/// </summary>
public record ForceCancelAbsenceRequestCommand(Guid Id) : IRequest<Result>;
