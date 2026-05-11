using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.AbsenceRequests.Commands.CancelAbsenceRequest;

/// <summary>
/// Soft-cancel an absence request. Only allowed while the matching trip
/// hasn't started yet (i.e. no in-progress / completed trip already covers
/// the requested leg on the requested date).
/// </summary>
public record CancelAbsenceRequestCommand(Guid Id) : IRequest<Result>;
