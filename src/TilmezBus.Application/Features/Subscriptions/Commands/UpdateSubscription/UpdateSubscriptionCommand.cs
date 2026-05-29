using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Subscriptions.Commands.UpdateSubscription;

public record UpdateSubscriptionCommand(
    Guid SubscriptionId,
    SubscriptionType SubscriptionType,
    int MaxStudents,
    int MaxBuses,
    DateTime ActivationDate,
    DateTime ExpirationDate,
    bool IsActive,
    decimal Price,
    PaymentStatus PaymentStatus,
    decimal RemainingAmount,
    bool EnableQr,
    bool EnableNfc
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "students:page:*" };
}
