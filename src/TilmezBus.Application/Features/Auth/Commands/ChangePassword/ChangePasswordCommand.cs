using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.ChangePassword;

public record ChangePasswordCommand(
    string UserId,
    string CurrentPassword,
    string NewPassword
) : IRequest<Result>;
