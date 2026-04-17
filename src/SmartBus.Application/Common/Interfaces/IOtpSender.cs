namespace SmartBus.Application.Common.Interfaces;

/// <summary>
/// Abstraction over SMS/OTP delivery. Swap the implementation for a real
/// provider (Twilio, Unifonic, etc.) without touching business logic.
/// </summary>
public interface IOtpSender
{
    /// <summary>Send a one-time password to the given phone number.</summary>
    Task SendAsync(string phoneNumber, string otp, CancellationToken cancellationToken = default);
}
