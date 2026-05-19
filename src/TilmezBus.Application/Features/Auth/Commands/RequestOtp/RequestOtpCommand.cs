using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.RequestOtp;

/// <param name="PhoneNumber">Mobile number of the user (E.164 or local format).</param>
public record RequestOtpCommand(string PhoneNumber) : IRequest<Result<RequestOtpResponse>>;

public record RequestOtpResponse(
    string Message,
    int ExpiresInSeconds,
    string Role,       // resolved from the phone: Parent | Driver | Assistant
    string? Otp        // returned only in Development — null in Production
);
