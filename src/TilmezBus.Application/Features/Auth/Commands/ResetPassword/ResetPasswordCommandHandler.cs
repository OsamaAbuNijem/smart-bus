using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.ResetPassword;

public class ResetPasswordCommandHandler
    : IRequestHandler<ResetPasswordCommand, Result>
{
    private readonly IUserStore _userStore;

    public ResetPasswordCommandHandler(IUserStore userStore) => _userStore = userStore;

    public async Task<Result> Handle(ResetPasswordCommand request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
            return Result.Failure("Email is required.");
        if (string.IsNullOrWhiteSpace(request.Token))
            return Result.Failure("Invalid or expired reset link.");
        if (string.IsNullOrWhiteSpace(request.NewPassword))
            return Result.Failure("Password is required.");

        var (ok, err) = await _userStore.ResetPasswordWithTokenAsync(
            request.Email.Trim(), request.Token, request.NewPassword, ct);
        return ok
            ? Result.Success()
            : Result.Failure(err ?? "Could not reset the password.");
    }
}
