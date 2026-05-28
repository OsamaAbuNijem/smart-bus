using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Infrastructure.Services;

/// <summary>
/// Development / stub implementation — logs the OTP to the console
/// instead of sending it via a real channel. Used when no Prelude API
/// key is configured (local dev / CI).
/// </summary>
public sealed class DevOtpSender : IOtpSender
{
    private readonly ILogger<DevOtpSender> _logger;

    public DevOtpSender(ILogger<DevOtpSender> logger) => _logger = logger;

    public Task SendAsync(string phoneNumber, string code, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("[OTP-DEV] Phone: {Phone} — Code: {Code}", phoneNumber, code);
        return Task.CompletedTask;
    }
}
