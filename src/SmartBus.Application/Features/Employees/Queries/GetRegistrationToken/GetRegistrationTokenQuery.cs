using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Employees.Queries.GetRegistrationToken;

/// <summary>
/// Mobile-app prefetch right after a QR scan and before the user fills in
/// the registration form — lets the app render "Register as Driver" /
/// "Register as Assistant" with the school name as a header.
/// </summary>
public record GetRegistrationTokenQuery(string Token) : IRequest<Result<RegistrationTokenInfoDto>>;

public record RegistrationTokenInfoDto(
    string Token,
    string Type,
    bool IsUsed,
    Guid SchoolId,
    string SchoolName,
    string SchoolCity
);
