using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.VerifyOtp;

/// <param name="PhoneNumber">Same phone used in RequestOtp.</param>
/// <param name="Otp">6-digit code received by the user.</param>
public record VerifyOtpCommand(string PhoneNumber, string Otp) : IRequest<Result<OtpLoginResponse>>;

public record OtpLoginResponse(
    string Token,
    DateTime ExpiresAt,
    string Role,
    string FullName,
    string PhoneNumber,
    Guid   EntityId,    // Driver / Parent / Assistant table Id
    string RefreshToken
);
