using MediatR;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Subscriptions.Queries.GetSubscriptionPayments;

public record GetSubscriptionPaymentsQuery(Guid SubscriptionId)
    : IRequest<IReadOnlyList<SubscriptionPaymentDto>>;

public record SubscriptionPaymentDto(
    Guid Id,
    Guid SubscriptionId,
    DateTime PaymentDate,
    decimal  Amount,
    PaymentMethod Method,
    DateTime CreatedAt
);
