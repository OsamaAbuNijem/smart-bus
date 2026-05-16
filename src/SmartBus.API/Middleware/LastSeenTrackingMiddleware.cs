using System.Collections.Concurrent;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using SmartBus.Infrastructure.Persistence;

namespace SmartBus.API.Middleware;

/// <summary>
/// Stamps <c>ApplicationUser.LastSeenAt</c> with the current UTC time on every
/// authenticated request. Used by the SuperAdmin dashboard's "currently
/// active users" metric — JWTs are stateless, so we approximate "logged in
/// right now" with "made an authenticated request in the last 15 minutes".
///
/// Throttled per user (<see cref="ThrottleSeconds"/>) so the dashboard hot
/// path doesn't issue an UPDATE on every single API call.
/// </summary>
public class LastSeenTrackingMiddleware
{
    private const int ThrottleSeconds = 60;
    private static readonly ConcurrentDictionary<string, DateTime> _lastWriteByUser = new();

    private readonly RequestDelegate _next;

    public LastSeenTrackingMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext context, ApplicationDbContext db)
    {
        // Run the rest of the pipeline first — we only need the user id, and
        // updating LastSeenAt in the background after the response is sent
        // would be even better. For now this is synchronous-cheap (one UPDATE
        // every 60s per user) so we do it inline.
        await _next(context);

        var userId = context.User?.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userId)) return;

        var now = DateTime.UtcNow;
        if (_lastWriteByUser.TryGetValue(userId, out var last)
            && (now - last).TotalSeconds < ThrottleSeconds)
            return;

        try
        {
            // Single-row UPDATE, no entity tracking — cheaper than a full
            // Find()+SaveChanges() roundtrip.
            await db.Users
                .Where(u => u.Id == userId)
                .ExecuteUpdateAsync(s => s.SetProperty(u => u.LastSeenAt, now));
            _lastWriteByUser[userId] = now;
        }
        catch
        {
            // LastSeenAt is best-effort telemetry — never let a DB hiccup
            // block the request. The pipeline already ran above so the
            // user's response is already on the wire.
        }
    }
}
