namespace SmartBus.Application.Common.Interfaces;

/// <summary>
/// Resolves a school's currently active subscription. "Active" means
/// IsActive = true AND now ∈ [ActivationDate, ExpirationDate].
/// Returns null when the school has no live subscription — callers
/// should treat that as "admin panel is gated".
/// </summary>
public interface IActiveSubscriptionService
{
    Task<Guid?> GetActiveSubscriptionIdAsync(Guid schoolId, CancellationToken cancellationToken = default);
}
