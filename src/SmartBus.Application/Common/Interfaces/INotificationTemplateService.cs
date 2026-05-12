using SmartBus.Domain.Enums;

namespace SmartBus.Application.Common.Interfaces;

/// <summary>
/// Resolves the user-visible title + message for a given notification type
/// from the database-backed template table, substituting `{placeholder}`
/// tokens. Falls back to Arabic when the requested language is unavailable.
/// </summary>
public interface INotificationTemplateService
{
    Task<(string Title, string Message)> RenderAsync(
        NotificationType type,
        string languageCode,
        IReadOnlyDictionary<string, string?> placeholders,
        CancellationToken ct = default);
}
