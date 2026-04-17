using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Auth.Commands.ChangePassword;

public record ChangePasswordCommand(
    string UserId,
    string CurrentPassword,
    string NewPassword
) : IRequest<Result>;
