using FirebaseAdmin.Messaging;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Enums;
using SmartBus.Infrastructure.Persistence;

namespace SmartBus.Infrastructure.Services;

/// <summary>
/// Sends FCM messages to every device token registered for a user, and prunes
/// the table of tokens FCM tells us are stale (UNREGISTERED / INVALID_ARGUMENT).
/// </summary>
public class FcmPushNotificationService : IPushNotificationService
{
    private readonly ApplicationDbContext _db;
    private readonly ILogger<FcmPushNotificationService> _logger;

    public FcmPushNotificationService(
        ApplicationDbContext db,
        ILogger<FcmPushNotificationService> logger)
    {
        _db = db;
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
        _db.Notifications.Add(new SmartBus.Domain.Entities.Notification
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

        // Prune tokens FCM rejected as permanently invalid.
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
            _logger.LogInformation(
                "Pruned {Count} stale FCM tokens for user {UserId}",
                stale.Count, userId);
        }

        return response.SuccessCount;
    }
}
