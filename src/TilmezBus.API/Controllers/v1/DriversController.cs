using System.Security.Claims;
using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Features.Drivers.Commands.CreateDriver;
using TilmezBus.Application.Features.Drivers.Commands.DeleteDriver;
using TilmezBus.Application.Features.Drivers.Commands.UpdateDriver;
using TilmezBus.Application.Features.Drivers.Commands.UpdateMyProfile;
using TilmezBus.Application.Features.Drivers.Queries.GetAllDrivers;
using TilmezBus.Application.Features.Drivers.Queries.GetDriverById;
using TilmezBus.Application.Features.Schools.Queries.GetMyFleetSchool;
using TilmezBus.Application.Features.Schools.Queries.GetMySchool;
using TilmezBus.Domain.Enums;

namespace TilmezBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class DriversController : ControllerBase
{
    private readonly IMediator _mediator;

    public DriversController(IMediator mediator) => _mediator = mediator;

    /// <summary>
    /// Self-update for the authenticated driver/assistant. Used by the
    /// mobile settings screen.
    /// </summary>
    [HttpPut("me")]
    [Authorize(Roles = "Driver,Assistant")]
    public async Task<IActionResult> UpdateMe(
        [FromBody] UpdateMyProfileCommand command,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] DriverType? driverType = null,
        CancellationToken cancellationToken = default)
    {
        var schoolId = await ResolveAdminSchoolIdAsync(cancellationToken);
        return Ok(await _mediator.Send(new GetAllDriversQuery(pageNumber, pageSize, driverType, schoolId), cancellationToken));
    }

    /// <summary>
    /// Resolve the school for the calling user. Admin path first (email →
    /// School.AdminEmail); on miss, fleet path (userId → Driver/Assistant.UserId).
    /// Returns null for SA / unauthenticated callers.
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

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetDriverByIdQuery(id), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateDriverCommand command, CancellationToken cancellationToken)
    {
        // Stamp the calling admin's school onto the new row regardless of
        // what (if anything) the client sent — Driver/Assistant must belong
        // to the admin's tenant.
        var schoolId = await ResolveAdminSchoolIdAsync(cancellationToken);
        if (schoolId is null) return BadRequest(new { error = "School not found for this admin." });
        var scoped = command with { SchoolId = schoolId };
        var result = await _mediator.Send(scoped, cancellationToken);
        return result.IsSuccess
            ? CreatedAtAction(nameof(GetById), new { id = result.Data }, result.Data)
            : BadRequest(new { error = result.Error });
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateDriverRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new UpdateDriverCommand(id, request.FullName, request.FullNameEn, request.PhoneNumber, request.IsActive, request.DriverType),
            cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new DeleteDriverCommand(id), cancellationToken);
        return result.IsSuccess ? NoContent() : NotFound(new { error = result.Error });
    }
}

public record UpdateDriverRequest(
    string? FullName = null,
    string? FullNameEn = null,
    string? PhoneNumber = null,
    bool? IsActive = null,
    DriverType? DriverType = null
);
