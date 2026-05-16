using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Subscriptions.Commands.CreateSubscription;

public record CreateSubscriptionCommand(
    Guid SchoolId,
    SubscriptionType SubscriptionType,
    int MaxStudents,
    int MaxBuses,
    DateTime ActivationDate,
    DateTime ExpirationDate,
    bool IsActive,
    decimal Price,
    PaymentStatus PaymentStatus,
    decimal RemainingAmount
) : IRequest<Result<Guid>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "students:page:*" };
}
