using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Infrastructure.Notifications;

/// <inheritdoc />
public class NotificationTemplateService : INotificationTemplateService
{
    private readonly IApplicationDbContext _context;

    public NotificationTemplateService(IApplicationDbContext context)
        => _context = context;

    public async Task<(string Title, string Message)> RenderAsync(
        NotificationType type,
        string languageCode,
        IReadOnlyDictionary<string, string?> placeholders,
        CancellationToken ct = default)
    {
        // Try the requested language first, then fall back to Arabic (the
        // app's default), then to any row of the same type.
        var template = await _context.NotificationTemplates
            .Where(t => t.Type == type && t.LanguageCode == languageCode)
            .FirstOrDefaultAsync(ct);
        template ??= await _context.NotificationTemplates
            .Where(t => t.Type == type && t.LanguageCode == "ar")
            .FirstOrDefaultAsync(ct);
        template ??= await _context.NotificationTemplates
            .Where(t => t.Type == type)
            .FirstOrDefaultAsync(ct);

        if (template is null)
        {
            // No row found — surface a recognisable placeholder so missing
            // copy is visible during development.
            return ($"[{type}]", $"[{type}]");
        }

        return (
            ApplyPlaceholders(template.Title, placeholders),
            ApplyPlaceholders(template.Message, placeholders));
    }

    private static string ApplyPlaceholders(
        string text, IReadOnlyDictionary<string, string?> values)
    {
        foreach (var (key, value) in values)
        {
            text = text.Replace("{" + key + "}", value ?? string.Empty);
        }
        return text;
    }
}
