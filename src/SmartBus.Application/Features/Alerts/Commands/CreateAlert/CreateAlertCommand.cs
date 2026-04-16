using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Alerts.Commands.CreateAlert;

public record CreateAlertCommand(
    string Title,
    string Message,
    AlertSeverity Severity = AlertSeverity.Normal,
    Guid? RelatedBusId = null,
    Guid? RelatedTripId = null,
    Guid? RelatedStudentId = null
) : IRequest<Result<Guid>>;
