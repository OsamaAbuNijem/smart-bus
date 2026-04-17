using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Auth.Commands.RequestOtp;

/// <param name="PhoneNumber">Mobile number of the user (E.164 or local format).</param>
/// <param name="Role">One of: Parent, Driver, Assistant</param>
public record RequestOtpCommand(string PhoneNumber, string Role) : IRequest<Result<RequestOtpResponse>>;

public record RequestOtpResponse(
    string Message,
    int ExpiresInSeconds,
    string? Otp        // returned only in Development — null in Production
);
