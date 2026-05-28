namespace TilmezBus.Application.Common.Exceptions;

/// <summary>
/// Thrown by IOtpSender implementations when the provider refuses to
/// deliver an OTP because of a per-number rate limit or fraud-guard
/// signal (Prelude's `status:"retry"` / `status:"blocked"`). Distinct
/// from a true error: the request reached the provider successfully,
/// they just declined to send right now.
///
/// Callers (the OTP command handler) catch this and convert it into a
/// 429-style user-facing failure instead of a generic 500.
/// </summary>
public sealed class OtpDeliveryRateLimitedException : Exception
{
    public OtpDeliveryRateLimitedException(string message) : base(message) { }
}
