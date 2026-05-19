namespace TilmezBus.Domain.Enums;

/// <summary>
/// 3-state payment status for a Subscription. Replaces the older boolean
/// IsPaid flag so the SuperAdmin can record partial payments (e.g. school
/// paid an instalment) without coupling the flag to RemainingAmount.
/// </summary>
public enum PaymentStatus
{
    Unpaid  = 0,
    Partial = 1,
    Paid    = 2
}
