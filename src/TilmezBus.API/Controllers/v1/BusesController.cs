using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TilmezBus.Application.Features.Buses.Commands.CreateBus;
using TilmezBus.Application.Features.Buses.Commands.CreateBusesBatch;
using TilmezBus.Application.Features.Buses.Commands.DeleteBus;
using TilmezBus.Application.Features.Buses.Commands.UpdateBus;
using TilmezBus.Application.Features.Schools.Queries.GetMyFleetSchool;
using TilmezBus.Application.Features.Schools.Queries.GetMySchool;
using TilmezBus.Application.Features.Buses.Commands.UpdateBusLocation;
using TilmezBus.Application.Features.Buses.Queries.GetAllBuses;
using TilmezBus.Application.Features.Buses.Queries.GetBusById;
using TilmezBus.Application.Features.Buses.Queries.GetBusByQrToken;
using TilmezBus.Application.Features.Buses.Queries.GetBusDefaultDriver;
using TilmezBus.Application.Features.Buses.Queries.GetBusLastRoster;
using TilmezBus.Domain.Enums;

namespace TilmezBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class BusesController : ControllerBase
{
    private readonly IMediator _mediator;

    public BusesController(IMediator mediator)
        => _mediator = mediator;

    /// <summary>Get all buses (paginated). Filtered by the calling admin's school.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(GetAllBusesQuery), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? plateNumber = null,
        [FromQuery] string? personName = null,
        CancellationToken cancellationToken = default)
    {
        var schoolId = await ResolveAdminSchoolIdAsync(cancellationToken);
        var result = await _mediator.Send(new GetAllBusesQuery(pageNumber, pageSize, plateNumber, personName, schoolId), cancellationToken);
        return Ok(result);
    }

    /// <summary>
    /// Resolve the school for the calling user. Tries the admin path first
    /// (email → School.AdminEmail), then falls back to the fleet path
    /// (userId → Driver/Assistant.UserId → SchoolId) so the mobile
    /// driver/assistant flows see only their own school's buses. Returns
    /// null for SuperAdmin / unauthenticated callers so the query layer
    /// can fall back to a cross-school view.
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

    /// <summary>Resolve a bus from its QR token. Used by the assistant scan flow.</summary>
    [HttpPost("by-qr")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> GetByQr(
        [FromBody] BusByQrRequest request,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new GetBusByQrTokenQuery(request.QrToken), cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { error = result.Error });
    }

    /// <summary>
    /// Roster for the last trip on this bus + trip type, used by the
    /// assistant trip-setup screen to preview students before starting.
    /// </summary>
    [HttpGet("{id:guid}/last-roster")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> LastRoster(
        Guid id,
        [FromQuery] TripType tripType,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new GetBusLastRosterQuery(id, tripType), cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Default driver for this bus + trip type, taken from the bus schedule.
    /// Used by the assistant trip-setup screen to pre-fill the driver picker.
    /// </summary>
    [HttpGet("{id:guid}/default-driver")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> DefaultDriver(
        Guid id,
        [FromQuery] TripType tripType,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new GetBusDefaultDriverQuery(id, tripType), cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }

    /// <summary>Get a bus by ID.</summary>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(BusDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetBusByIdQuery(id), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    /// <summary>Create a new bus.</summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(Guid), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create([FromBody] BusRequest request, CancellationToken cancellationToken)
    {
        var command = new CreateBusCommand(request.PlateNumber, request.Capacity ?? 50, request.Status ?? "Active");
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? CreatedAtAction(nameof(GetById), new { id = result.Data }, result.Data)
            : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Bulk-create N buses with auto-generated BUS-#### numbers, default
    /// capacity, Active status, and one QR token each. Used by the admin
    /// "add multiple buses" modal.
    /// </summary>
    [HttpPost("batch")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateBatch([FromBody] BusBatchRequest request, CancellationToken cancellationToken)
    {
        var schoolId = await ResolveAdminSchoolIdAsync(cancellationToken);
        if (schoolId is null) return BadRequest(new { error = "School not found for this admin." });
        var result = await _mediator.Send(new CreateBusesBatchCommand(request.Count, schoolId.Value), cancellationToken);
        return result.IsSuccess
            ? StatusCode(StatusCodes.Status201Created, new { created = result.Data })
            : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Partial update: omit fields the caller doesn't want to change. The
    /// admin grid uses this to toggle status / rename inline without
    /// re-sending the whole record.
    /// </summary>
    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Update(Guid id, [FromBody] BusRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateBusCommand(id, request.PlateNumber, request.Capacity, request.Status);
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    /// <summary>Delete a bus (soft delete).</summary>
    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new DeleteBusCommand(id), cancellationToken);
        return result.IsSuccess ? NoContent() : NotFound(new { error = result.Error });
    }

    /// <summary>Update bus GPS location (called by bus device).</summary>
    [HttpPost("{id:guid}/location")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateLocation(Guid id, [FromBody] UpdateLocationRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateBusLocationCommand(id, request.Latitude, request.Longitude, request.Speed, request.Heading);
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? NoContent() : NotFound(new { error = result.Error });
    }
}

public record UpdateLocationRequest(double Latitude, double Longitude, double? Speed, double? Heading);

public record BusByQrRequest(string QrToken);

public record BusRequest(
    string? PlateNumber = null,
    int? Capacity = null,
    string? Status = null);

public record BusBatchRequest(int Count);
