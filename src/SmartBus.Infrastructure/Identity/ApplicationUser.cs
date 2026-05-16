using Microsoft.AspNetCore.Identity;

namespace SmartBus.Infrastructure.Identity;

public class ApplicationUser : IdentityUser
{
    public string FullName { get; set; } = default!;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Updated on every authenticated API request by
    /// <c>LastSeenTrackingMiddleware</c> (throttled). The SuperAdmin dashboard
    /// counts users whose <c>LastSeenAt</c> is within the last 15 minutes as
    /// "currently active" — a stand-in for an active-sessions store since
    /// our JWTs are stateless.
    /// </summary>
    public DateTime? LastSeenAt { get; set; }
}
