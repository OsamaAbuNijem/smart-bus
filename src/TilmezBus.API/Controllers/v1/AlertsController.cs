using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Features.Alerts.Commands.CreateAlert;
using TilmezBus.Application.Features.Alerts.Commands.UpdateAlertStatus;
using TilmezBus.Application.Features.Alerts.Queries.GetAllAlerts;
using TilmezBus.Domain.Enums;

namespace TilmezBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class AlertsController : ControllerBase
{
    private readonly IMediator _mediator;

    public AlertsController(IMediator mediator) => _mediator = mediator;

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAll([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20, [FromQuery] AlertStatus? status = null, [FromQuery] AlertSeverity? severity = null, CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetAllAlertsQuery(pageNumber, pageSize, status, severity), cancellationToken));

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateAlertCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    [HttpPatch("{id:guid}/status")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateAlertStatusRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new UpdateAlertStatusCommand(id, request.Status), cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }
}

public record UpdateAlertStatusRequest(AlertStatus Status);
