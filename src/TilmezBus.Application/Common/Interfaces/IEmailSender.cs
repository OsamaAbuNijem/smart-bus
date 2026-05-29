namespace TilmezBus.Application.Common.Interfaces;

/// <summary>
/// Transactional email transport. Implementations should be idempotent
/// at the boundary (resend = send again — no dedup magic) and bubble
/// any provider error so the caller decides whether to retry.
/// </summary>
public interface IEmailSender
{
    /// <summary>Send a single HTML email. Plain-text fallback is derived
    /// by the implementation from the HTML body.</summary>
    Task SendAsync(string toEmail, string subject, string htmlBody, CancellationToken cancellationToken = default);
}
