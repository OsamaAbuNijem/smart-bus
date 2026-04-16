using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Alerts.Commands.UpdateAlertStatus;

public record UpdateAlertStatusCommand(Guid AlertId, AlertStatus Status) : IRequest<Result>;
