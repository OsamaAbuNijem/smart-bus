using MediatR;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Subscriptions.Queries.GetSchoolSubscriptions;

public record GetSchoolSubscriptionsQuery(Guid SchoolId) : IRequest<IReadOnlyList<SubscriptionDto>>;

public record SubscriptionDto(
    Guid Id,
    Guid SchoolId,
    SubscriptionType SubscriptionType,
    int MaxStudents,
    int MaxBuses,
    DateTime ActivationDate,
    DateTime ExpirationDate,
    bool IsActive,
    bool IsCurrentlyActive,   // IsActive && today ∈ [Activation, Expiration]
    decimal Price,
    bool IsPaid,
    decimal RemainingAmount,
    DateTime CreatedAt
);
