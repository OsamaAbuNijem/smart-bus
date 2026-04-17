using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Auth.Commands.ChangePassword;

public class ChangePasswordCommandHandler : IRequestHandler<ChangePasswordCommand, Result>
{
    private readonly IUserStore _userStore;

    public ChangePasswordCommandHandler(IUserStore userStore) => _userStore = userStore;

    public async Task<Result> Handle(ChangePasswordCommand request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 8)
            return Result.Failure("كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل.");

        var (succeeded, error) = await _userStore.ChangePasswordAsync(
            request.UserId, request.CurrentPassword, request.NewPassword, cancellationToken);

        return succeeded ? Result.Success() : Result.Failure(error ?? "فشل تغيير كلمة المرور.");
    }
}
