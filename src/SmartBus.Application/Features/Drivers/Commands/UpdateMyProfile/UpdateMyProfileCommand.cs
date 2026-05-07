using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Commands.UpdateMyProfile;

/// <summary>
/// Self-update for the currently authenticated driver/assistant — used by
/// the mobile settings screen.
/// </summary>
public record UpdateMyProfileCommand(
    string FullName,
    string PhoneNumber
) : IRequest<Result<UpdateMyProfileResponse>>;

public record UpdateMyProfileResponse(
    Guid Id,
    string FullName,
    string PhoneNumber);
