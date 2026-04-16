using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.AbsenceRequests.Commands.UpdateAbsenceRequestStatus;

public record UpdateAbsenceRequestStatusCommand(Guid RequestId, AbsenceRequestStatus Status) : IRequest<Result>;
