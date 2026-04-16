using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Attendance.Commands.RecordAttendance;
using SmartBus.Application.Features.Attendance.Queries.GetAttendanceByStudent;
using SmartBus.Application.Features.Attendance.Queries.GetAttendanceByTrip;

namespace SmartBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class AttendanceController : ControllerBase
{
    private readonly IMediator _mediator;

    public AttendanceController(IMediator mediator) => _mediator = mediator;

    /// <summary>Get attendance summary for a student with optional date range filter.</summary>
    [HttpGet("students/{studentId:guid}")]
    public async Task<IActionResult> GetByStudent(Guid studentId, [FromQuery] DateOnly? from, [FromQuery] DateOnly? to, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAttendanceByStudentQuery(studentId, from, to), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    /// <summary>Get attendance list for all students on a trip.</summary>
    [HttpGet("trips/{tripId:guid}")]
    public async Task<IActionResult> GetByTrip(Guid tripId, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAttendanceByTripQuery(tripId), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    /// <summary>Record or update attendance for a student on a trip.</summary>
    [HttpPost]
    [Authorize(Roles = "Admin,Driver,Assistant")]
    public async Task<IActionResult> Record([FromBody] RecordAttendanceCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }
}
