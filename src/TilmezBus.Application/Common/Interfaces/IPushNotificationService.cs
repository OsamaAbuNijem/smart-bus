using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Common.Interfaces;

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

    /// <summary>
    /// Sends a templated notification to a user, picking the language
    /// template per registered device. A parent with an Arabic phone and
    /// an English tablet gets each language in its own push. Also writes
    /// the message to the inbox once per language (so the in-app inbox
    /// shows the most-recently-used device's language).
    /// </summary>
    Task<int> SendTemplatedToUserAsync(
        string userId,
        NotificationType type,
        IReadOnlyDictionary<string, string?> templateVars,
        IDictionary<string, string>? data = null,
        Guid? relatedTripId = null,
        Guid? relatedBusId = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Pushes the given title/body via FCM only — does NOT write to the
    /// inbox. Used by SendNotificationCommandHandler which already
    /// persists its own Notification row (with RelatedTripId etc.) and
    /// just needs the FCM hop on top.
    /// </summary>
    Task<int> SendFcmOnlyToUserAsync(
        string userId,
        string title,
        string body,
        IDictionary<string, string>? data = null,
        CancellationToken cancellationToken = default);
}
