using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Localization;
using SmartBus.API.Resources;
using SmartBus.Application.Features.Auth.Commands.RequestOtp;
using SmartBus.Application.Features.Auth.Commands.VerifyOtp;

namespace SmartBus.API.Controllers.v1;

/// <summary>
/// OTP-based login for mobile users (Parent, Driver, Assistant).
/// </summary>
[ApiController]
[EnableRateLimiting("auth")]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/auth/otp")]
public class OtpController : ControllerBase
{
    private readonly IMediator                    _mediator;
    private readonly IHostEnvironment             _env;
    private readonly IStringLocalizer<ApiMessages> _L;

    public OtpController(IMediator mediator, IHostEnvironment env, IStringLocalizer<ApiMessages> localizer)
    {
        _mediator = mediator;
        _env      = env;
        _L        = localizer;
    }

    /// <summary>
    /// Request an OTP for a phone number.
    /// The OTP expires in 5 minutes. A new request cannot be made within 60 seconds.
    /// </summary>
    /// <remarks>
    /// Sample request:
    ///
    ///     POST /api/v1/auth/otp/request
    ///     {
    ///         "phoneNumber": "0501234567",
    ///         "role": "Parent"
    ///     }
    ///
    /// Valid roles: **Parent**, **Driver**, **Assistant**
    /// </remarks>
    [HttpPost("request")]
    [ProducesResponseType(typeof(RequestOtpResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Request(
        [FromBody] OtpRequestDto dto,
        CancellationToken cancellationToken)
    {
        if (!IsValidRole(dto.Role))
            return BadRequest(new { error = _L["Otp_RoleInvalid"].Value });

        var result = await _mediator.Send(
            new RequestOtpCommand(dto.PhoneNumber, dto.Role), cancellationToken);

        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });

        // Strip OTP from response in non-development environments
        var data = _env.IsDevelopment()
            ? result.Data
            : result.Data! with { Otp = null };

        return Ok(data);
    }

    /// <summary>
    /// Verify an OTP and receive a JWT token.
    /// </summary>
    /// <remarks>
    /// Sample request:
    ///
    ///     POST /api/v1/auth/otp/verify
    ///     {
    ///         "phoneNumber": "0501234567",
    ///         "otp": "123456",
    ///         "role": "Parent"
    ///     }
    ///
    /// On success returns a JWT token valid for 24 hours.
    /// </remarks>
    [HttpPost("verify")]
    [ProducesResponseType(typeof(OtpLoginResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Verify(
        [FromBody] OtpVerifyDto dto,
        CancellationToken cancellationToken)
    {
        if (!IsValidRole(dto.Role))
            return BadRequest(new { error = _L["Otp_RoleInvalid"].Value });

        var result = await _mediator.Send(
            new VerifyOtpCommand(dto.PhoneNumber, dto.Otp, dto.Role), cancellationToken);

        return result.IsSuccess
            ? Ok(result.Data)
            : Unauthorized(new { error = result.Error });
    }

    private static bool IsValidRole(string role)
        => role?.ToLower() is "parent" or "driver" or "assistant";
}

public record OtpRequestDto(string PhoneNumber, string Role);
public record OtpVerifyDto(string PhoneNumber, string Otp, string Role);
