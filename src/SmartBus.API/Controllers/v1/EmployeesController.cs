using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Employees.Commands.RegisterFromQr;
using SmartBus.Application.Features.Employees.Queries.GetRegistrationToken;

namespace SmartBus.API.Controllers.v1;

[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class EmployeesController : ControllerBase
{
    private readonly IMediator _mediator;

    public EmployeesController(IMediator mediator) => _mediator = mediator;

    /// <summary>
    /// Mobile-app prefetch — given the QR's opaque token, returns whether
    /// it's still redeemable plus the role + school it'll register the user as.
    /// Anonymous: the QR itself is the credential.
    /// </summary>
    [HttpGet("registration-token/{token}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetRegistrationToken(string token, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetRegistrationTokenQuery(token), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    /// <summary>
    /// Mobile-app submit — creates the Driver/Assistant + Identity user from
    /// the form data, marks the token consumed, and returns a JWT so the app
    /// auto-logs in. Anonymous because the user has no account yet.
    /// </summary>
    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<IActionResult> Register([FromBody] RegisterFromQrRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new RegisterFromQrCommand(request.Token, request.FullName, request.PhoneNumber),
            cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }
}

public record RegisterFromQrRequest(string Token, string FullName, string PhoneNumber);
