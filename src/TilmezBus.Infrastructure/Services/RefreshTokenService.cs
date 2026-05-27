using System.Security.Cryptography;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;
using TilmezBus.Infrastructure.Persistence;

namespace TilmezBus.Infrastructure.Services;

public sealed class RefreshTokenService : IRefreshTokenService
{
    /// <summary>Refresh tokens are good for 30 days; after that the user
    /// goes back through the OTP flow once.</summary>
    public static readonly TimeSpan Lifetime = TimeSpan.FromDays(30);

    private readonly ApplicationDbContext _db;
    private readonly ILogger<RefreshTokenService> _logger;

    public RefreshTokenService(ApplicationDbContext db, ILogger<RefreshTokenService> logger)
    {
        _db = db;
        _logger = logger;
    }

    public async Task<string> IssueAsync(string userId, CancellationToken ct = default)
    {
        var (raw, hash) = GenerateTokenPair();
        _db.RefreshTokens.Add(new RefreshToken
        {
            UserId    = userId,
            TokenHash = hash,
            ExpiresAt = DateTime.UtcNow.Add(Lifetime),
        });
        await _db.SaveChangesAsync(ct);
        return raw;
    }

    public async Task<RefreshResult?> ValidateAndRotateAsync(
        string rawToken, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(rawToken)) return null;
        var hash = HashToken(rawToken);

        var existing = await _db.RefreshTokens
            .FirstOrDefaultAsync(t => t.TokenHash == hash, ct);
        if (existing is null) return null;

        // Re-use of a revoked token is the canonical theft signal —
        // wipe every active token for this user so the attacker AND the
        // legitimate device are both forced back through OTP.
        if (existing.RevokedAt is not null)
        {
            _logger.LogWarning(
                "Refresh token re-use detected for user {UserId}; revoking chain.",
                existing.UserId);
            await RevokeAllForUserAsync(existing.UserId, ct);
            return null;
        }

        if (DateTime.UtcNow >= existing.ExpiresAt) return null;

        // Rotate: issue a new token, link the chain, persist atomically.
        var (newRaw, newHash) = GenerateTokenPair();
        var replacement = new RefreshToken
        {
            UserId    = existing.UserId,
            TokenHash = newHash,
            ExpiresAt = DateTime.UtcNow.Add(Lifetime),
        };
        _db.RefreshTokens.Add(replacement);
        await _db.SaveChangesAsync(ct);

        existing.RevokedAt          = DateTime.UtcNow;
        existing.ReplacedByTokenId  = replacement.Id;
        await _db.SaveChangesAsync(ct);

        return new RefreshResult(existing.UserId, newRaw);
    }

    public async Task RevokeAllForUserAsync(string userId, CancellationToken ct = default)
    {
        var now = DateTime.UtcNow;
        await _db.RefreshTokens
            .Where(t => t.UserId == userId && t.RevokedAt == null)
            .ExecuteUpdateAsync(s => s
                .SetProperty(t => t.RevokedAt, now)
                .SetProperty(t => t.UpdatedAt, now), ct);
    }

    // ── helpers ────────────────────────────────────────────────────────

    private static (string raw, string hash) GenerateTokenPair()
    {
        // 64 random bytes → base64url. ~344-bit entropy, comfortable
        // headroom above the threshold for practical-brute-force concerns.
        Span<byte> bytes = stackalloc byte[64];
        RandomNumberGenerator.Fill(bytes);
        var raw = Convert.ToBase64String(bytes)
            .TrimEnd('=').Replace('+', '-').Replace('/', '_');
        return (raw, HashToken(raw));
    }

    private static string HashToken(string raw)
    {
        Span<byte> hash = stackalloc byte[32];
        SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(raw), hash);
        return Convert.ToHexString(hash);
    }
}
