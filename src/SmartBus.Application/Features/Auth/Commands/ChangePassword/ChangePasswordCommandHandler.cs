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
            return Result.Failure(T("كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل.",
                                    "New password must be at least 8 characters."));

        var (succeeded, error) = await _userStore.ChangePasswordAsync(
            request.UserId, request.CurrentPassword, request.NewPassword, cancellationToken);

        return succeeded ? Result.Success() : Result.Failure(error ?? T("فشل تغيير كلمة المرور.", "Failed to change password."));
    }

    private static string T(string ar, string en) =>
        System.Globalization.CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ar" ? ar : en;
}
