using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Infrastructure.Services;

/// <summary>
/// Development / stub implementation — logs that an OTP "send" was
/// requested and accepts the master code <c>1234</c> on verify. Used
/// when no Prelude API key is configured so local dev / CI keep working.
/// </summary>
public sealed class DevOtpSender : IOtpSender
{
    private readonly ILogger<DevOtpSender> _logger;

    public DevOtpSender(ILogger<DevOtpSender> logger) => _logger = logger;

    public Task SendAsync(string phoneNumber, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation(
            "[OTP-DEV] Pretend-send to {Phone}. Use master code 1234 in dev.", phoneNumber);
        return Task.CompletedTask;
    }

    public Task<bool> VerifyAsync(string phoneNumber, string code, CancellationToken cancellationToken = default)
    {
        // VerifyOtpCommandHandler also gates on dev-env + master code
        // before reaching here; this is defence in depth.
        return Task.FromResult(code == "1234");
    }
}
