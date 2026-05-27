using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.RefreshToken;

public class RefreshTokenCommandHandler
    : IRequestHandler<RefreshTokenCommand, Result<RefreshTokenResponse>>
{
    private readonly IRefreshTokenService _refresh;
    private readonly IJwtService          _jwt;
    private readonly IUserStore           _userStore;

    public RefreshTokenCommandHandler(
        IRefreshTokenService refresh, IJwtService jwt, IUserStore userStore)
    {
        _refresh   = refresh;
        _jwt       = jwt;
        _userStore = userStore;
    }

    private static string T(string ar, string en) =>
        System.Globalization.CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ar" ? ar : en;

    public async Task<Result<RefreshTokenResponse>> Handle(
        RefreshTokenCommand request, CancellationToken ct)
    {
        var rotated = await _refresh.ValidateAndRotateAsync(request.RefreshToken, ct);
        if (rotated is null)
        {
            return Result<RefreshTokenResponse>.Failure(
                T("جلسة منتهية، يرجى تسجيل الدخول مرة أخرى.",
                  "Session expired, please log in again."));
        }

        var user = await _userStore.FindByIdAsync(rotated.UserId, ct);
        if (user is null)
        {
            // User was deleted between issue and refresh — revoke the
            // freshly-rotated token so it can't be used either.
            await _refresh.RevokeAllForUserAsync(rotated.UserId, ct);
            return Result<RefreshTokenResponse>.Failure(
                T("الحساب غير موجود.", "Account not found."));
        }

        var roles = (await _userStore.GetRolesAsync(rotated.UserId, ct)).ToList();
        var token = _jwt.GenerateToken(rotated.UserId, user.Email, roles);
        // Mirror JwtService.AccessTokenLifetime (1h).
        var exp   = DateTime.UtcNow.AddHours(1);

        return Result<RefreshTokenResponse>.Success(
            new RefreshTokenResponse(token, exp, rotated.NewRawToken));
    }
}
