using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Subscriptions.Commands.UpdateSubscription;

public record UpdateSubscriptionCommand(
    Guid SubscriptionId,
    SubscriptionType SubscriptionType,
    int MaxStudents,
    int MaxBuses,
    DateTime ActivationDate,
    DateTime ExpirationDate,
    bool IsActive,
    decimal Price,
    bool IsPaid,
    decimal RemainingAmount
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "students:page:*" };
}
