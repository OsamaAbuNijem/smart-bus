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
    /// Request an OTP for a phone number. The role is auto-detected from the
    /// phone (Parent / Driver / Assistant) and returned in the response.
    /// </summary>
    /// <remarks>
    /// Sample request:
    ///
    ///     POST /api/v1/auth/otp/request
    ///     {
    ///         "phoneNumber": "+962791234567"
    ///     }
    /// </remarks>
    [HttpPost("request")]
    [ProducesResponseType(typeof(RequestOtpResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Request(
        [FromBody] OtpRequestDto dto,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new RequestOtpCommand(dto.PhoneNumber), cancellationToken);

        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });

        var data = _env.IsDevelopment()
            ? result.Data
            : result.Data! with { Otp = null };

        return Ok(data);
    }

    /// <summary>Verify an OTP and receive a JWT token.</summary>
    [HttpPost("verify")]
    [ProducesResponseType(typeof(OtpLoginResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Verify(
        [FromBody] OtpVerifyDto dto,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new VerifyOtpCommand(dto.PhoneNumber, dto.Otp), cancellationToken);

        return result.IsSuccess
            ? Ok(result.Data)
            : Unauthorized(new { error = result.Error });
    }
}

public record OtpRequestDto(string PhoneNumber);
public record OtpVerifyDto(string PhoneNumber, string Otp);
