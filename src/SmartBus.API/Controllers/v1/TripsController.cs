using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Trips.Commands.CreateTrip;
using SmartBus.Application.Features.Trips.Commands.CancelEmptyTrip;
using SmartBus.Application.Features.Trips.Commands.DeleteTrip;
using SmartBus.Application.Features.Trips.Commands.ScanBusQr;
using SmartBus.Application.Features.Trips.Commands.ScanStudent;
using SmartBus.Application.Features.Trips.Commands.SetBusSchedule;
using SmartBus.Application.Features.Trips.Commands.StartTrip;
using SmartBus.Application.Features.Trips.Commands.UpdateTrip;
using SmartBus.Application.Features.Trips.Commands.UpdateTripStatus;
using SmartBus.Application.Features.Trips.Queries.GetAllBusSchedules;
using SmartBus.Application.Features.Trips.Queries.GetAllTrips;
using SmartBus.Application.Features.Trips.Queries.GetBusSchedule;
using SmartBus.Application.Features.Trips.Queries.GetMyTodayTrips;
using SmartBus.Application.Features.Trips.Queries.GetTripDetails;
using SmartBus.Application.Features.Trips.Queries.GetTripStudents;
using SmartBus.Domain.Enums;

namespace SmartBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class TripsController : ControllerBase
{
    private readonly IMediator _mediator;

    public TripsController(IMediator mediator)
        => _mediator = mediator;

    /// <summary>Scan a student QR on a live trip — marks them as Boarded.</summary>
    [HttpPost("{id:guid}/scan-student")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> ScanStudent(
        Guid id,
        [FromBody] ScanStudentRequest request,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new ScanStudentCommand(id, request.QrToken, request.Latitude, request.Longitude),
            cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Trip details for the assistant's live trip screen: header + students
    /// enriched with parent contact + absence flag, sorted by home area.
    /// </summary>
    [HttpGet("{id:guid}/details")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> GetDetails(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetTripDetailsQuery(id), cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : NotFound(new { error = result.Error });
    }

    /// <summary>
    /// Create and start a new trip with the given bus, driver, and trip type.
    /// Roster is auto-loaded from the last trip on (bus, type), or — failing
    /// that — from the bus schedule. Replaces /trips/scan for the assistant flow.
    /// </summary>
    [HttpPost("start")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> Start(
        [FromBody] StartTripCommand command,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }

    /// <summary>Today's trips for the current driver/assistant (one row per leg).</summary>
    [HttpGet("my-today")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> GetMyToday(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetMyTodayTripsQuery(), cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? personName = null,
        [FromQuery] string? date = null,
        [FromQuery] string? status = null,
        CancellationToken cancellationToken = default)
    {
        DateOnly? parsedDate = DateOnly.TryParse(date, out var d) ? d : null;
        var result = await _mediator.Send(
            new GetAllTripsQuery(pageNumber, pageSize, personName, parsedDate, status),
            cancellationToken);
        return Ok(result);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateTripCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateTripRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new UpdateTripCommand(id, request.Name, request.Type, request.BusId, request.RouteId, request.ScheduledDeparture, request.RepeatDays, request.Notes),
            cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    [HttpPatch("{id:guid}/status")]
    [Authorize(Roles = "Admin,Driver")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateStatusRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new UpdateTripStatusCommand(id, request.Status, request.Notes), cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Mobile-app entry point — driver/assistant scans a bus QR sticker.
    /// On success, the server creates (or returns the existing) trip and the
    /// app navigates straight into the live tracking / boarding view.
    /// </summary>
    [HttpPost("scan")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> Scan([FromBody] ScanBusQrRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new ScanBusQrCommand(request.QrToken), cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }

    /// <summary>Get all saved bus schedules (used by the buses grid to show schedule status).</summary>
    [HttpGet("schedules")]
    public async Task<IActionResult> GetAllSchedules(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAllBusSchedulesQuery(), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    /// <summary>Get the ذهاب/إياب schedule for a specific bus.</summary>
    [HttpGet("bus/{busId:guid}/schedule")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetBusSchedule(Guid busId, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetBusScheduleQuery(busId), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    /// <summary>Set (create or update) the ذهاب/إياب schedule for a bus.</summary>
    [HttpPost("bus/{busId:guid}/schedule")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> SetBusSchedule(Guid busId, [FromBody] BusScheduleRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new SetBusScheduleCommand(
                busId,
                request.MorningTime,
                request.ReturnTime,
                request.RepeatDays,
                request.MorningDriverId,
                request.MorningAssistantId,
                request.ReturnDriverId,
                request.ReturnAssistantId,
                request.StudentIds ?? Array.Empty<Guid>()
            ),
            cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    /// <summary>Get students (with trip details) for a specific trip.</summary>
    [HttpGet("{id:guid}/students")]
    public async Task<IActionResult> GetStudents(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetTripStudentsQuery(id), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    /// <summary>Mark a trip as In Progress (sets ActualDeparture to now).</summary>
    [HttpPost("{id:guid}/start")]
    [Authorize(Roles = "Admin,Driver,Assistant")]
    public async Task<IActionResult> Start(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new UpdateTripStatusCommand(id, Domain.Enums.TripStatus.InProgress),
            cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    /// <summary>Mark a trip as Completed (sets ActualArrival to now).</summary>
    [HttpPost("{id:guid}/complete")]
    [Authorize(Roles = "Admin,Driver,Assistant")]
    public async Task<IActionResult> Complete(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new UpdateTripStatusCommand(id, Domain.Enums.TripStatus.Completed),
            cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new DeleteTripCommand(id), cancellationToken);
        return result.IsSuccess ? NoContent() : NotFound(new { error = result.Error });
    }

    /// <summary>
    /// Cancel a trip that has zero students. Used by the assistant flow
    /// when the trip was started with "Skip auto-roster" and no student
    /// was scanned — there is nothing to complete, so the trip is deleted.
    /// </summary>
    [HttpDelete("{id:guid}/empty")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> CancelEmpty(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new CancelEmptyTripCommand(id), cancellationToken);
        return result.IsSuccess
            ? NoContent()
            : BadRequest(new { error = result.Error });
    }
}

public record UpdateStatusRequest(TripStatus Status, string? Notes);
public record UpdateTripRequest(string Name, TripType Type, Guid BusId, Guid? RouteId, DateTime ScheduledDeparture, byte RepeatDays, string? Notes);
public record ScanBusQrRequest(string QrToken);
public record BusScheduleRequest(
    string MorningTime,
    string ReturnTime,
    byte RepeatDays,
    Guid? MorningDriverId,
    Guid? MorningAssistantId,
    Guid? ReturnDriverId,
    Guid? ReturnAssistantId,
    IReadOnlyList<Guid>? StudentIds
);

public record ScanStudentRequest(string QrToken, double? Latitude = null, double? Longitude = null);
