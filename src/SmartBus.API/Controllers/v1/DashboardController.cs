using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using SmartBus.Application.Features.Dashboard.Queries.GetAdminDashboardStats;
using SmartBus.Application.Features.Dashboard.Queries.GetLiveDashboardStats;
using SmartBus.Application.Features.Schools.Queries.GetMyFleetSchool;
using SmartBus.Application.Features.Schools.Queries.GetMySchool;

namespace SmartBus.API.Controllers.v1;

/// <summary>
/// School-admin dashboard aggregates. Scoped to the calling admin's school
/// so the page paints all KPIs in one roundtrip without leaking other
/// tenants' counts.
/// </summary>
[Authorize(Roles = "Admin")]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class DashboardController : ControllerBase
{
    private readonly IMediator _mediator;

    public DashboardController(IMediator mediator) => _mediator = mediator;

    /// <summary>
    /// Returns headline totals (students, buses, drivers, assistants, trips)
    /// plus today's trips/students/absents bucketed by trip type
    /// (Today / Morning / Return). Single MediatR call, single DB roundtrip
    /// per counter.
    /// </summary>
    [HttpGet("admin-stats")]
    public async Task<IActionResult> AdminStats(CancellationToken cancellationToken)
    {
        var schoolId = await ResolveAdminSchoolIdAsync(cancellationToken);
        if (schoolId is null) return Forbid();

        var dto = await _mediator.Send(new GetAdminDashboardStatsQuery(schoolId.Value), cancellationToken);
        return Ok(dto);
    }

    /// <summary>
    /// Real-time view of in-progress trips for the calling admin's school:
    /// trip + boarded-student counts (overall / morning / return) and a
    /// per-trip list with a projected end-time the client counts down.
    /// </summary>
    [HttpGet("live")]
    public async Task<IActionResult> Live(CancellationToken cancellationToken)
    {
        var schoolId = await ResolveAdminSchoolIdAsync(cancellationToken);
        if (schoolId is null) return Forbid();

        var dto = await _mediator.Send(new GetLiveDashboardStatsQuery(schoolId.Value), cancellationToken);
        return Ok(dto);
    }

    /// <summary>
    /// Resolves the calling admin's school. Tries the admin path first
    /// (email → School.AdminEmail) then falls back to fleet membership
    /// (userId → Driver/Assistant.SchoolId).
    /// </summary>
    private async Task<Guid?> ResolveAdminSchoolIdAsync(CancellationToken cancellationToken)
    {
        var email  = User.FindFirstValue(ClaimTypes.Email);
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!string.IsNullOrEmpty(email))
        {
            var school = await _mediator.Send(new GetMySchoolQuery(email), cancellationToken);
            if (school.IsSuccess) return school.Data!.Id;
        }
        if (!string.IsNullOrEmpty(userId))
        {
            var fleetSchoolId = await _mediator.Send(new GetMyFleetSchoolQuery(userId), cancellationToken);
            if (fleetSchoolId is not null) return fleetSchoolId;
        }
        return null;
    }
}
