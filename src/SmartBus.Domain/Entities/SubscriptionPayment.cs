using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Entities;

/// <summary>
/// A single payment recorded against a <see cref="Subscription"/>. The
/// SuperAdmin logs each instalment as the school pays; the dashboard /
/// drawer can sum these to show how much has been collected so far.
/// </summary>
public class SubscriptionPayment : BaseEntity
{
    public Guid SubscriptionId { get; set; }
    public Subscription? Subscription { get; set; }

    public DateTime PaymentDate { get; set; }
    public decimal  Amount      { get; set; }
    public PaymentMethod Method { get; set; } = PaymentMethod.Cash;
}
