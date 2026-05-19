using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Alerts.Commands.UpdateAlertStatus;

public record UpdateAlertStatusCommand(Guid AlertId, AlertStatus Status) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "alerts:page:*" };
}
