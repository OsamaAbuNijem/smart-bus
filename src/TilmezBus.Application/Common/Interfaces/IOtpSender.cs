namespace TilmezBus.Application.Common.Interfaces;

/// <summary>
/// Abstraction over OTP delivery. We generate the code locally and the
/// sender's only job is to get it to the user (Prelude as the carrier
/// pipeline, or the dev console logger). Verification happens against
/// the Redis-cached code in the command handler — providers no longer
/// own the code value.
/// </summary>
public interface IOtpSender
{
    /// <summary>Deliver the given OTP to the given phone number. The
    /// concrete provider chooses the channel and renders the message;
    /// the code itself is supplied by the caller.</summary>
    Task SendAsync(string phoneNumber, string code, CancellationToken cancellationToken = default);
}
