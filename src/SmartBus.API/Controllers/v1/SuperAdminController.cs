using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.SuperAdmin.Queries.GetDashboardStats;

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
}
