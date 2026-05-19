using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Employees.Commands.RegisterFromQr;

/// <summary>
/// Anonymous endpoint hit by the mobile app after scanning a school's
/// employee QR. Creates the Driver/Assistant record + Identity user from the
/// data the user typed in (name, phone), reads the role from the token's
/// <c>Type</c>, and returns a JWT so the app can auto-login.
/// </summary>
public record RegisterFromQrCommand(
    string Token,
    string FullName,
    string PhoneNumber
) : IRequest<Result<RegisterFromQrResponse>>;

public record RegisterFromQrResponse(
    string Token,                  // JWT — driver/assistant can start using the app immediately
    DateTime ExpiresAt,
    string Role,                   // "Driver" | "Assistant"
    string FullName,
    string PhoneNumber,
    Guid EmployeeId                // The newly-created Driver.Id or Assistant.Id
);
