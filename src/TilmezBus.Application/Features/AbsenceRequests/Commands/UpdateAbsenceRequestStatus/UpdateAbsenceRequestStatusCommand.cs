using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.AbsenceRequests.Commands.UpdateAbsenceRequestStatus;

public record UpdateAbsenceRequestStatusCommand(Guid RequestId, AbsenceRequestStatus Status) : IRequest<Result>;
