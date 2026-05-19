using System.Security.Claims;
using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Features.DemoRequests.Commands.CompleteDemoRequest;
using TilmezBus.Application.Features.DemoRequests.Queries.GetAllDemoRequests;
using TilmezBus.Application.Features.SuperAdmin.Commands.ImpersonateSchoolAdmin;
using TilmezBus.Application.Features.SuperAdmin.Commands.SendBroadcast;
using TilmezBus.Application.Features.SuperAdmin.Queries.GetBroadcasts;
using TilmezBus.Application.Features.SuperAdmin.Queries.GetDashboardStats;
using TilmezBus.Domain.Enums;

namespace TilmezBus.API.Controllers.v1;

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

    /// <summary>
    /// Mint a JWT for a school's admin user (no password required). The
    /// SuperAdmin's UI swaps this token into its session so it can operate
    /// the admin dashboard with full privileges; calling Stop swaps the
    /// SA's original token back.
    /// </summary>
    [HttpPost("impersonate/{schoolId:guid}")]
    public async Task<IActionResult> Impersonate(Guid schoolId, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new ImpersonateSchoolAdminCommand(schoolId), cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }

    /// <summary>Paginated demo-request queue from the public landing page.</summary>
    [HttpGet("demo-requests")]
    public async Task<IActionResult> ListDemoRequests(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize   = 20,
        [FromQuery] DemoRequestStatus? status = null,
        CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetAllDemoRequestsQuery(pageNumber, pageSize, status), cancellationToken));

    /// <summary>
    /// Flip a demo request to Completed once the SuperAdmin has reached out
    /// to the school. Idempotent — re-calling on an already-completed row
    /// is a no-op.
    /// </summary>
    [HttpPost("demo-requests/{id:guid}/complete")]
    public async Task<IActionResult> CompleteDemoRequest(Guid id, CancellationToken cancellationToken)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var result = await _mediator.Send(new CompleteDemoRequestCommand(id, userId), cancellationToken);
        return result.IsSuccess
            ? Ok(new { ok = true })
            : BadRequest(new { error = result.Error });
    }
}

public record SendBroadcastRequest(
    string Title,
    string Message,
    BroadcastTarget Target,
    IReadOnlyList<Guid>? SchoolIds);
