namespace TilmezBus.Domain.Enums;

/// <summary>
/// How a SubscriptionPayment was received. Each payment line carries one
/// of these so the SuperAdmin can later reconcile cash vs bank transfers.
/// </summary>
public enum PaymentMethod
{
    Cash     = 0,
    Transfer = 1,
    Cheque   = 2
}
