using SmartBus.Domain.Enums;

namespace SmartBus.Application.Common.Interfaces;

/// <summary>
/// Sends push notifications to one or many user devices via FCM and records
/// the message in the inbox so it appears on the in-app notifications page.
/// Failures for individual tokens are swallowed and stale tokens are pruned,
/// so this is best-effort from the caller's perspective.
/// </summary>
public interface IPushNotificationService
{
    /// <summary>
    /// Sends a notification to every device currently registered for the
    /// given user and persists it to the in-app inbox. Returns the number
    /// of devices the FCM message was delivered to.
    /// </summary>
    Task<int> SendToUserAsync(
        string userId,
        string title,
        string body,
        NotificationType type = NotificationType.SystemAlert,
        IDictionary<string, string>? data = null,
        CancellationToken cancellationToken = default);
}
