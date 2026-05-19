using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Alerts.Commands.CreateAlert;

public record CreateAlertCommand(
    string Title,
    string Message,
    AlertSeverity Severity = AlertSeverity.Normal,
    Guid? RelatedBusId = null,
    Guid? RelatedTripId = null,
    Guid? RelatedStudentId = null
) : IRequest<Result<Guid>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "alerts:page:*" };
}
