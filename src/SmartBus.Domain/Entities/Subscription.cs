using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Entities;

/// <summary>
/// A super-admin–managed window of service for a school. Exactly one
/// subscription per school is expected to be "active" at any time
/// (IsActive=true AND ActivationDate &lt;= now &lt;= ExpirationDate).
/// When the window closes, the admin panel stops surfacing students linked
/// to it; a new subscription is created and students get linked to that one
/// instead — without duplicating the students themselves.
/// </summary>
public class Subscription : BaseEntity
{
    public Guid SchoolId { get; set; }
    public School? School { get; set; }

    public int MaxStudents { get; set; }
    public int MaxBuses { get; set; }

    public DateTime ActivationDate { get; set; }
    public DateTime ExpirationDate { get; set; }

    public bool IsActive { get; set; } = true;

    public decimal Price { get; set; }
    /// <summary>
    /// 3-state payment status. Replaces the older boolean IsPaid so the
    /// SuperAdmin can record partial payments without overloading
    /// RemainingAmount as a payment flag.
    /// </summary>
    public PaymentStatus PaymentStatus { get; set; } = PaymentStatus.Unpaid;
    public decimal RemainingAmount { get; set; }

    public SubscriptionType SubscriptionType { get; set; } = SubscriptionType.Trial;

    public ICollection<SubscriptionStudent> StudentLinks { get; set; } = new List<SubscriptionStudent>();

    /// <summary>
    /// Payment instalments recorded against this subscription. The
    /// SuperAdmin logs each one (cash or transfer) so the platform has a
    /// receipts trail; RemainingAmount / PaymentStatus remain the
    /// SuperAdmin's call rather than auto-derived from this collection.
    /// </summary>
    public ICollection<SubscriptionPayment> Payments { get; set; } = new List<SubscriptionPayment>();
}
