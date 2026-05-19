using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Features.DemoRequests.Commands.CreateDemoRequest;

namespace TilmezBus.API.Controllers.v1;

/// <summary>
/// Public "Request a demo" endpoint used by the marketing landing page.
/// Anonymous on purpose — the form is submitted by prospective school
/// admins before they have any credentials.
/// </summary>
[AllowAnonymous]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/demo-requests")]
public class DemoRequestsController : ControllerBase
{
    private readonly IMediator _mediator;

    public DemoRequestsController(IMediator mediator) => _mediator = mediator;

    [HttpPost]
    public async Task<IActionResult> Submit([FromBody] DemoRequestSubmission body, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new CreateDemoRequestCommand(
                SchoolName:  body.SchoolName,
                ContactName: body.ContactName,
                Email:       body.Email,
                PhoneNumber: body.PhoneNumber,
                Notes:       body.Notes),
            cancellationToken);
        return result.IsSuccess
            ? Ok(new { id = result.Data })
            : BadRequest(new { error = result.Error });
    }
}

public record DemoRequestSubmission(
    string  SchoolName,
    string  ContactName,
    string  Email,
    string? PhoneNumber,
    string? Notes);
