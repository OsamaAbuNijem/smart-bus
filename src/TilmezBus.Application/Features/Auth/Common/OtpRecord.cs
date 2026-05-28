namespace TilmezBus.Application.Features.Auth.Common;

/// <summary>
/// Server-owned OTP state cached in Redis between
/// <c>/auth/otp/request</c> and <c>/auth/otp/verify</c>. Lifetime
/// matches <c>OtpTtlSeconds</c>; attempts increment on each wrong
/// guess up to <c>MaxAttempts</c>.
/// </summary>
internal sealed record OtpRecord(string Code, DateTime CreatedAt, int Attempts);
