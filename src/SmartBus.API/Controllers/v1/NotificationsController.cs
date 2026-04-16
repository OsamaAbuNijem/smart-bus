using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Notifications.Commands.MarkNotificationAsRead;
using SmartBus.Application.Features.Notifications.Commands.SendNotification;
using SmartBus.Application.Features.Notifications.Queries.GetNotificationsByRecipient;

namespace SmartBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class NotificationsController : ControllerBase
{
    private readonly IMediator _mediator;

    public NotificationsController(IMediator mediator) => _mediator = mediator;

    /// <summary>Get notifications for a recipient (parent/driver/assistant userId).</summary>
    [HttpGet("{recipientId}")]
    public async Task<IActionResult> GetByRecipient(string recipientId, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetNotificationsByRecipientQuery(recipientId, pageNumber, pageSize), cancellationToken));

    /// <summary>Send a notification (admin only).</summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Send([FromBody] SendNotificationCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    /// <summary>Mark a notification as read.</summary>
    [HttpPatch("{id:guid}/read")]
    public async Task<IActionResult> MarkAsRead(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new MarkNotificationAsReadCommand(id), cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }
}
