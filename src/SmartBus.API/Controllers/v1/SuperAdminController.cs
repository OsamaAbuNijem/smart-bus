using System.Security.Claims;
using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.SuperAdmin.Commands.SendBroadcast;
using SmartBus.Application.Features.SuperAdmin.Queries.GetBroadcasts;
using SmartBus.Application.Features.SuperAdmin.Queries.GetDashboardStats;
using SmartBus.Domain.Enums;

namespace SmartBus.API.Controllers.v1;

/// <summary>
/// Cross-tenant endpoints reserved for the SuperAdmin. Currently exposes
/// the dashboard aggregate; future SA-only reads can land here too.
/// </summary>
[Authorize(Roles = "SuperAdmin")]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/superadmin")]
public class SuperAdminController : ControllerBase
{
    private readonly IMediator _mediator;

    public SuperAdminController(IMediator mediator) => _mediator = mediator;

    /// <summary>
    /// One-shot dashboard aggregate: schools / active-subs, buses, drivers
    /// + assistants, students, active users per role, and today's trips
    /// bucketed by status.
    /// </summary>
    [HttpGet("dashboard")]
    public async Task<IActionResult> Dashboard(CancellationToken cancellationToken)
        => Ok(await _mediator.Send(new GetDashboardStatsQuery(), cancellationToken));

    /// <summary>List recent SuperAdmin broadcasts (newest first).</summary>
    [HttpGet("notifications")]
    public async Task<IActionResult> ListBroadcasts([FromQuery] int limit = 50, CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetBroadcastsQuery(limit), cancellationToken));

    /// <summary>
    /// Send a push broadcast to the chosen audience and append a row to
    /// the SuperAdmin broadcast history. Audience options described on
    /// <see cref="BroadcastTarget"/>.
    /// </summary>
    [HttpPost("notifications")]
    public async Task<IActionResult> SendBroadcast([FromBody] SendBroadcastRequest request, CancellationToken cancellationToken)
    {
        var senderUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var result = await _mediator.Send(
            new SendBroadcastCommand(
                Title:        request.Title,
                Message:      request.Message,
                Target:       request.Target,
                SchoolIds:    request.SchoolIds ?? Array.Empty<Guid>(),
                SentByUserId: senderUserId),
            cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }
}

public record SendBroadcastRequest(
    string Title,
    string Message,
    BroadcastTarget Target,
    IReadOnlyList<Guid>? SchoolIds);
