using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.Login;

public class LoginCommandHandler : IRequestHandler<LoginCommand, Result<LoginResponse>>
{
    private readonly IJwtService _jwtService;
    private readonly IUserStore _userStore;

    public LoginCommandHandler(IJwtService jwtService, IUserStore userStore)
    {
        _jwtService = jwtService;
        _userStore = userStore;
    }

    public async Task<Result<LoginResponse>> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var user = await _userStore.FindByEmailAsync(request.Email, cancellationToken);
        if (user is null)
            return Result<LoginResponse>.Failure("Invalid email or password.");

        var isValid = await _userStore.CheckPasswordAsync(user.Id, request.Password, cancellationToken);
        if (!isValid)
            return Result<LoginResponse>.Failure("Invalid email or password.");

        var roles = await _userStore.GetRolesAsync(user.Id, cancellationToken);
        var token = _jwtService.GenerateToken(user.Id, user.Email, roles);
        var expiresAt = DateTime.UtcNow.AddHours(24);

        return Result<LoginResponse>.Success(new LoginResponse(token, user.Email, roles, expiresAt));
    }
}
