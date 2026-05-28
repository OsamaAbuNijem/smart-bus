namespace TilmezBus.Application.Common.Interfaces;

/// <summary>
/// Abstraction over OTP delivery + verification. The provider owns code
/// generation, storage, expiry, and attempt counting (e.g. Twilio Verify
/// v2); the handler stays oblivious to the code value.
/// </summary>
public interface IOtpSender
{
    /// <summary>Trigger delivery of a fresh OTP to the given phone number.
    /// The code itself is never exposed to the caller.</summary>
    Task SendAsync(string phoneNumber, CancellationToken cancellationToken = default);

    /// <summary>Check whether the supplied code matches the most recent OTP
    /// the provider sent to this phone number. Returns true only on the
    /// provider's explicit "approved" status; any other state is false.</summary>
    Task<bool> VerifyAsync(string phoneNumber, string code, CancellationToken cancellationToken = default);
}
