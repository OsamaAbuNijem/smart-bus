using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Alerts.Queries.GetAllAlerts;

public record GetAllAlertsQuery(
    int PageNumber = 1,
    int PageSize = 20,
    AlertStatus? Status = null,
    AlertSeverity? Severity = null
) : IRequest<PagedResult<AlertDto>>, ICacheableQuery
{
    public string CacheKey => $"alerts:page:{PageNumber}:size:{PageSize}:st:{Status?.ToString() ?? "_"}:sv:{Severity?.ToString() ?? "_"}";
    public TimeSpan? CacheExpiry => TimeSpan.FromSeconds(30);
}

public record AlertDto(Guid Id, string Title, string Message, AlertSeverity Severity, AlertStatus Status, DateTime CreatedAt);
