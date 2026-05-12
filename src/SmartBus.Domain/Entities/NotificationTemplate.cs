using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Entities;

/// <summary>
/// A localized template for a specific <see cref="NotificationType"/>. The
/// title and message use simple `{placeholder}` tokens that the notification
/// pipeline substitutes at send-time, so the user-visible copy lives in the
/// database (editable per language) rather than in the handlers.
/// </summary>
public class NotificationTemplate : BaseEntity
{
    public NotificationType Type { get; set; }

    /// <summary>BCP-47 language tag, e.g. "ar" or "en".</summary>
    public string LanguageCode { get; set; } = default!;

    public string Title { get; set; } = default!;
    public string Message { get; set; } = default!;
}
