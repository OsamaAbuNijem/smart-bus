using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Infrastructure.Services;

/// <summary>
/// Development / stub implementation — logs the OTP instead of sending SMS.
/// Replace with a real SMS provider (Twilio, Unifonic, etc.) in production.
/// </summary>
public sealed class DevOtpSender : IOtpSender
{
    private readonly ILogger<DevOtpSender> _logger;

    public DevOtpSender(ILogger<DevOtpSender> logger) => _logger = logger;

    public Task SendAsync(string phoneNumber, string otp, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("[OTP] Phone: {Phone} — Code: {Otp}", phoneNumber, otp);
        // TODO: replace with real SMS provider
        return Task.CompletedTask;
    }
}
