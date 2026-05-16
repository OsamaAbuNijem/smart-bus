using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Subscriptions.Commands.CreateSubscriptionPayment;

/// <summary>
/// Records a single payment instalment against a subscription. RemainingAmount
/// + PaymentStatus on the parent Subscription are left as-is — they remain
/// the SuperAdmin's explicit responsibility on the subscription form.
/// </summary>
public record CreateSubscriptionPaymentCommand(
    Guid SubscriptionId,
    DateTime      PaymentDate,
    decimal       Amount,
    PaymentMethod Method
) : IRequest<Result<Guid>>;
