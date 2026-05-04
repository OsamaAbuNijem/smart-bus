namespace SmartBus.Application.Common.Interfaces;

/// <summary>
/// Sends push notifications to one or many user devices via FCM. Failures
/// for individual tokens are swallowed and stale tokens are pruned, so this
/// is best-effort from the caller's perspective.
/// </summary>
public interface IPushNotificationService
{
    /// <summary>
    /// Sends a notification to every device currently registered for the
    /// given user. Returns the number of tokens delivered to.
    /// </summary>
    Task<int> SendToUserAsync(
        string userId,
        string title,
        string body,
        IDictionary<string, string>? data = null,
        CancellationToken cancellationToken = default);
}
