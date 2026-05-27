using TilmezBus.Domain.Common;

namespace TilmezBus.Domain.Entities;

/// <summary>
/// Long-lived refresh token for the mobile auth flow. The raw token is
/// shown to the client exactly once (in the OTP-verify / refresh response);
/// the server only stores a SHA-256 hash of it so a DB leak doesn't grant
/// sessions. Each refresh call rotates the token — the old row is marked
/// revoked and linked to its replacement.
/// </summary>
public class RefreshToken : BaseEntity
{
    /// <summary>AspNetUsers.Id of the owning user.</summary>
    public string UserId { get; set; } = default!;

    /// <summary>Hex-encoded SHA-256 of the raw refresh token. Lookups are
    /// always by this hash; the raw token never round-trips through us.</summary>
    public string TokenHash { get; set; } = default!;

    /// <summary>UTC expiry. Tokens past this are rejected even when valid.</summary>
    public DateTime ExpiresAt { get; set; }

    /// <summary>Set when the token is rotated, logged out, or detected as
    /// stolen. A non-null value disqualifies the token from refresh.</summary>
    public DateTime? RevokedAt { get; set; }

    /// <summary>When this token was rotated, points at the new row that
    /// took its place. Lets us reason about the rotation chain (and detect
    /// re-use of a revoked token as a theft signal).</summary>
    public Guid? ReplacedByTokenId { get; set; }

    public bool IsActive => RevokedAt is null && DateTime.UtcNow < ExpiresAt;
}
