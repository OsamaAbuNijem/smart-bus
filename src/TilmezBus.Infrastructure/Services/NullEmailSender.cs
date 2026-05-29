using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Infrastructure.Services;

/// <summary>
/// Logging fallback used when no <c>Email:Host</c> is configured.
/// Lets local dev / CI run the forgot-password flow end-to-end and
/// inspect the would-be email body in the server logs.
/// </summary>
public sealed class NullEmailSender : IEmailSender
{
    private readonly ILogger<NullEmailSender> _logger;
    public NullEmailSender(ILogger<NullEmailSender> logger) => _logger = logger;

    public Task SendAsync(string toEmail, string subject, string htmlBody, CancellationToken ct = default)
    {
        _logger.LogInformation(
            "[EMAIL-DEV] Pretend-send to {To} (subject={Subject}). Body length={Len} chars.",
            toEmail, subject, htmlBody.Length);
        return Task.CompletedTask;
    }
}
