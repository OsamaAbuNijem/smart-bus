using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.ResetPassword;

public record ResetPasswordCommand(
    string Email,
    string Token,
    string NewPassword) : IRequest<Result>;
