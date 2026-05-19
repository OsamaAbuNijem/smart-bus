using TilmezBus.Domain.Common;

namespace TilmezBus.Domain.Entities;

/// <summary>
/// FCM (Firebase Cloud Messaging) device token registered by a mobile client.
/// One user may have multiple rows (phone + tablet, reinstall churns tokens).
/// The combination of UserId + Token is unique — re-registering the same
/// token is a no-op upsert.
/// </summary>
public class UserDeviceToken : BaseEntity
{
    /// <summary>Identity user id (string, matches AspNetUsers.Id).</summary>
    public string UserId { get; set; } = default!;

    /// <summary>FCM token. Up to 4KB in worst case; stored as nvarchar(MAX).</summary>
    public string Token { get; set; } = default!;

    /// <summary>Lower-case platform tag: "android", "ios", "web".</summary>
    public string Platform { get; set; } = "android";

    public DateTime LastSeenAt { get; set; } = DateTime.UtcNow;
}
