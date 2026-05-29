using FirebaseAdmin.Messaging;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Enums;
using TilmezBus.Infrastructure.Persistence;

namespace TilmezBus.Infrastructure.Services;

/// <summary>
/// Sends FCM messages to every device token registered for a user, and prunes
/// the table of tokens FCM tells us are stale (UNREGISTERED / INVALID_ARGUMENT).
/// </summary>
public class FcmPushNotificationService : IPushNotificationService
{
    private readonly ApplicationDbContext _db;
    private readonly ILogger<FcmPushNotificationService> _logger;
    private readonly INotificationTemplateService _templates;

    public FcmPushNotificationService(
        ApplicationDbContext db,
        INotificationTemplateService templates,
        ILogger<FcmPushNotificationService> logger)
    {
        _db = db;
        _templates = templates;
        _logger = logger;
    }

    public async Task<int> SendToUserAsync(
        string userId,
        string title,
        string body,
        NotificationType type = NotificationType.SystemAlert,
        IDictionary<string, string>? data = null,
        CancellationToken cancellationToken = default)
    {
        // Persist to the inbox first — even if FCM is unreachable the user
        // will see the notification next time they open the app.
        _db.Notifications.Add(new TilmezBus.Domain.Entities.Notification
        {
            Title = title,
            Message = body,
            Type = type,
            RecipientId = userId,
            IsRead = false,
        });
        await _db.SaveChangesAsync(cancellationToken);

        var tokens = await _db.UserDeviceTokens
            .Where(t => t.UserId == userId)
            .Select(t => t.Token)
            .ToListAsync(cancellationToken);

        if (tokens.Count == 0) return 0;

        var message = new MulticastMessage
        {
            Tokens = tokens,
            Notification = new Notification { Title = title, Body = body },
            Data = data?.ToDictionary(kv => kv.Key, kv => kv.Value),
            Android = new AndroidConfig
            {
                Priority = Priority.High,
                Notification = new AndroidNotification
                {
                    ChannelId = "smartbus_default",
                    Sound     = "default",
                },
            },
            // iOS needs aps.sound on the APNs payload — without it the
            // notification surfaces silently regardless of the device's
            // ringer state. Default sound + the same alert title/body
            // FCM derives from the top-level Notification block.
            Apns = new ApnsConfig
            {
                Aps = new Aps
                {
                    Sound = "default",
                },
            },
        };

        BatchResponse response;
        try
        {
            response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(
                message, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "FCM send failed for user {UserId}", userId);
            return 0;
        }

        // Prune tokens FCM rejected as permanently invalid, and log the
        // error code for any other rejection so we can diagnose delivery
        // issues (third-party auth, sender-id mismatch, etc.).
        var stale = new List<string>();
        for (var i = 0; i < response.Responses.Count; i++)
        {
            var r = response.Responses[i];
            if (r.IsSuccess) continue;
            var code = r.Exception?.MessagingErrorCode;
            _logger.LogWarning(
                "FCM rejected token for user {UserId}: code={Code} message={Message}",
                userId, code, r.Exception?.Message);
            if (code == MessagingErrorCode.Unregistered ||
                code == MessagingErrorCode.InvalidArgument)
            {
                stale.Add(tokens[i]);
            }
        }
        if (stale.Count > 0)
        {
            await _db.UserDeviceTokens
                .Where(t => t.UserId == userId && stale.Contains(t.Token))
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(t => t.IsDeleted, true)
                    .SetProperty(t => t.UpdatedAt, DateTime.UtcNow),
                    cancellationToken);
            _logger.LogInformation(
                "Pruned {Count} stale FCM tokens for user {UserId}",
                stale.Count, userId);
        }

        return response.SuccessCount;
    }

    public async Task<int> SendTemplatedToUserAsync(
        string userId,
        NotificationType type,
        IReadOnlyDictionary<string, string?> templateVars,
        IDictionary<string, string>? data = null,
        CancellationToken cancellationToken = default)
    {
        // Group the user's tokens by language so each device gets the
        // template rendered in the language it last registered as. Null /
        // blank language → "ar" fallback (the operator-facing language).
        var devices = await _db.UserDeviceTokens
            .Where(t => t.UserId == userId)
            .Select(t => new { t.Token, Lang = t.Language })
            .ToListAsync(cancellationToken);

        if (devices.Count == 0) return 0;

        // Inbox row written once per distinct language so the in-app
        // notifications screen shows each user's preferred translation.
        // (Most users have one language and one row; multi-language users
        // see one entry per language they're registered with.)
        var langGroups = devices
            .GroupBy(d => string.IsNullOrWhiteSpace(d.Lang) ? "ar" : d.Lang!)
            .ToList();

        var sent = 0;
        foreach (var group in langGroups)
        {
            var lang = group.Key;
            string title, body;
            try
            {
                (title, body) = await _templates.RenderAsync(
                    type, lang, templateVars, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex,
                    "Template render failed for type={Type} lang={Lang} user={UserId}",
                    type, lang, userId);
                continue;
            }

            // Inbox row (one per language group).
            _db.Notifications.Add(new TilmezBus.Domain.Entities.Notification
            {
                Title = title,
                Message = body,
                Type = type,
                RecipientId = userId,
                IsRead = false,
            });
            await _db.SaveChangesAsync(cancellationToken);

            var tokens = group.Select(d => d.Token).ToList();
            var message = new MulticastMessage
            {
                Tokens = tokens,
                Notification = new Notification { Title = title, Body = body },
                Data = data?.ToDictionary(kv => kv.Key, kv => kv.Value),
                Android = new AndroidConfig
                {
                    Priority = Priority.High,
                    Notification = new AndroidNotification
                    {
                        ChannelId = "smartbus_default",
                    },
                },
            };

            BatchResponse response;
            try
            {
                response = await FirebaseMessaging.DefaultInstance
                    .SendEachForMulticastAsync(message, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex,
                    "FCM send failed for user {UserId} lang {Lang}", userId, lang);
                continue;
            }
            sent += response.SuccessCount;

            // Prune permanently-invalid tokens for this language batch.
            var stale = new List<string>();
            for (var i = 0; i < response.Responses.Count; i++)
            {
                var r = response.Responses[i];
                if (r.IsSuccess) continue;
                var code = r.Exception?.MessagingErrorCode;
                if (code == MessagingErrorCode.Unregistered ||
                    code == MessagingErrorCode.InvalidArgument)
                {
                    stale.Add(tokens[i]);
                }
            }
            if (stale.Count > 0)
            {
                await _db.UserDeviceTokens
                    .Where(t => t.UserId == userId && stale.Contains(t.Token))
                    .ExecuteUpdateAsync(setters => setters
                        .SetProperty(t => t.IsDeleted, true)
                        .SetProperty(t => t.UpdatedAt, DateTime.UtcNow),
                        cancellationToken);
            }
        }

        return sent;
    }
}
