namespace TilmezBus.Application.Common.Interfaces;

/// <summary>
/// Issuance, rotation, and revocation of long-lived refresh tokens used
/// by the mobile auth flow. Implementations must:
///   * store only a hash of the raw token (never the raw value)
///   * return the raw token to the caller exactly once (on issue/rotate)
///   * detect token re-use as a theft signal and revoke the user's chain
/// </summary>
public interface IRefreshTokenService
{
    /// <summary>Generate, persist (as hash), and return a fresh refresh
    /// token for the user. The returned string is the raw token to hand
    /// to the client — it never round-trips through the server again.</summary>
    Task<string> IssueAsync(string userId, CancellationToken cancellationToken = default);

    /// <summary>Validate a refresh token presented by the client and rotate
    /// it. On success returns (userId, newRawToken); the old token is
    /// marked revoked and linked to its replacement. Returns null when the
    /// token is unknown / expired / already revoked.</summary>
    Task<RefreshResult?> ValidateAndRotateAsync(string rawToken, CancellationToken cancellationToken = default);

    /// <summary>Revoke every active refresh token for a user — used on
    /// logout and on detected theft.</summary>
    Task RevokeAllForUserAsync(string userId, CancellationToken cancellationToken = default);
}

public record RefreshResult(string UserId, string NewRawToken);
