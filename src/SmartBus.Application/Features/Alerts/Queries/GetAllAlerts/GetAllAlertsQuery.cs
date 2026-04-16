using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Alerts.Queries.GetAllAlerts;

public record GetAllAlertsQuery(
    int PageNumber = 1,
    int PageSize = 20,
    AlertStatus? Status = null,
    AlertSeverity? Severity = null
) : IRequest<PagedResult<AlertDto>>;

public record AlertDto(Guid Id, string Title, string Message, AlertSeverity Severity, AlertStatus Status, DateTime CreatedAt);
