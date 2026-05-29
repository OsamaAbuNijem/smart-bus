using System.Security.Claims;
using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Features.Auth.Commands.ChangePassword;
using TilmezBus.Application.Features.Auth.Commands.Login;
using TilmezBus.Application.Features.Auth.Commands.RefreshToken;
using TilmezBus.Application.Features.Auth.Commands.RequestPasswordReset;
using TilmezBus.Application.Features.Auth.Commands.ResetPassword;

namespace TilmezBus.API.Controllers.v1;

[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
[EnableRateLimiting("auth")]
public class AuthController : ControllerBase
{
    private readonly IMediator            _mediator;
    private readonly IRefreshTokenService _refresh;

    public AuthController(IMediator mediator, IRefreshTokenService refresh)
    {
        _mediator = mediator;
        _refresh  = refresh;
    }

    /// <summary>Authenticate and receive a JWT token.</summary>
    [HttpPost("login")]
    [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : Unauthorized(new { error = result.Error });
    }

    /// <summary>Change the authenticated user's password.</summary>
    [HttpPost("change-password")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ChangePassword(
        [FromBody] ChangePasswordRequest request,
        CancellationToken cancellationToken)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userId))
            return Unauthorized();

        var result = await _mediator.Send(
            new ChangePasswordCommand(userId, request.CurrentPassword, request.NewPassword),
            cancellationToken);

        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Exchange a refresh token for a new access + refresh token pair.
    /// The old refresh token is revoked on success (rotation).
    /// </summary>
    [HttpPost("refresh")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(RefreshTokenResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Refresh(
        [FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new RefreshTokenCommand(request.RefreshToken), cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : Unauthorized(new { error = result.Error });
    }

    /// <summary>
    /// Revoke every active refresh token for the calling user. The
    /// current access token is left alone — it expires within 1h anyway.
    /// </summary>
    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Logout(CancellationToken cancellationToken)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!string.IsNullOrEmpty(userId))
            await _refresh.RevokeAllForUserAsync(userId, cancellationToken);
        return NoContent();
    }

    /// <summary>
    /// Start a password reset for an admin email. Always returns 204
    /// regardless of whether the email exists, so attackers can't use
    /// this endpoint to enumerate registered accounts. When the email
    /// matches, an email with a tokenised reset link is sent.
    /// </summary>
    [HttpPost("forgot-password")]
    [AllowAnonymous]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> ForgotPassword(
        [FromBody] ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new RequestPasswordResetCommand(request.Email), cancellationToken);
        return NoContent();
    }

    /// <summary>
    /// Complete a password reset using the token from the email link.
    /// </summary>
    [HttpPost("reset-password")]
    [AllowAnonymous]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ResetPassword(
        [FromBody] ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new ResetPasswordCommand(request.Email, request.Token, request.NewPassword),
            cancellationToken);
        return result.IsSuccess
            ? NoContent()
            : BadRequest(new { error = result.Error });
    }
}

public record ChangePasswordRequest(string CurrentPassword, string NewPassword);
public record RefreshTokenRequest(string RefreshToken);
public record ForgotPasswordRequest(string Email);
public record ResetPasswordRequest(string Email, string Token, string NewPassword);
