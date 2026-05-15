using System.Security.Claims;
using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Schools.Queries.GetMySchool;
using SmartBus.Application.Features.Students.Commands.BulkUpsertStudents;
using SmartBus.Application.Features.Students.Commands.CreateStudent;
using SmartBus.Application.Features.Students.Commands.DeleteStudent;
using SmartBus.Application.Features.Students.Commands.RegisterFromQr;
using SmartBus.Application.Features.Students.Commands.ScanQr;
using SmartBus.Application.Features.Students.Commands.UpdateStudent;
using SmartBus.Application.Features.Students.Queries.GetAllStudents;
using SmartBus.Application.Features.Students.Queries.GetStudentById;
using SmartBus.Application.Features.Students.Queries.GetStudentRegistrationToken;

namespace SmartBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class StudentsController : ControllerBase
{
    private readonly IMediator _mediator;

    public StudentsController(IMediator mediator) => _mediator = mediator;

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] Guid? routeId = null,
        [FromQuery] string? name = null,
        [FromQuery] string? grade = null,
        [FromQuery] string? homeArea = null,
        CancellationToken cancellationToken = default)
    {
        // Resolve the requesting admin's school so the query handler can
        // scope by school + active subscription. SuperAdmin requests without
        // a school context get an empty page; cross-school browsing should
        // use a dedicated SuperAdmin endpoint.
        Guid? schoolId = null;
        var email = User.FindFirstValue(ClaimTypes.Email);
        if (!string.IsNullOrEmpty(email))
        {
            var schoolResult = await _mediator.Send(new GetMySchoolQuery(email), cancellationToken);
            if (schoolResult.IsSuccess) schoolId = schoolResult.Data!.Id;
        }

        return Ok(await _mediator.Send(
            new GetAllStudentsQuery(pageNumber, pageSize, routeId, name, grade, homeArea, schoolId),
            cancellationToken));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetStudentByIdQuery(id), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateStudentRequest request, CancellationToken cancellationToken)
    {
        var email = User.FindFirstValue(ClaimTypes.Email);
        if (string.IsNullOrEmpty(email)) return Unauthorized();

        var schoolResult = await _mediator.Send(new GetMySchoolQuery(email), cancellationToken);
        if (!schoolResult.IsSuccess) return BadRequest(new { error = "School not found for this admin." });

        var command = new CreateStudentCommand(
            schoolResult.Data!.Id.ToString(),
            request.FullName, request.FullNameEn, request.NationalNumber ?? string.Empty,
            request.Grade, request.Class, request.DateOfBirth,
            request.Address, request.ParentName, request.ParentPhone,
            request.ParentId, request.RouteId, request.PickupStopId,
            request.Latitude, request.Longitude, request.HomeArea, request.HomeStreet, request.HomeBuildingNumber);

        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? CreatedAtAction(nameof(GetById), new { id = result.Data }, result.Data)
            : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Admin Excel import — upsert N student rows in a single round trip.
    /// Match key is NationalNumber; existing rows are updated, missing rows are
    /// created. Address/GPS fields are not touched (they aren't part of the
    /// import sheet, so we preserve any value already stored on the row).
    /// </summary>
    [HttpPost("bulk-upsert")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> BulkUpsert([FromBody] BulkUpsertStudentsRequest request, CancellationToken cancellationToken)
    {
        var email = User.FindFirstValue(ClaimTypes.Email);
        if (string.IsNullOrEmpty(email)) return Unauthorized();

        var schoolResult = await _mediator.Send(new GetMySchoolQuery(email), cancellationToken);
        if (!schoolResult.IsSuccess) return BadRequest(new { error = "School not found for this admin." });

        var command = new BulkUpsertStudentsCommand(
            schoolResult.Data!.Id.ToString(),
            request.Rows ?? Array.Empty<BulkUpsertStudentRow>());

        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { error = result.Error });
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateStudentRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateStudentCommand(
            id, request.FullName, request.FullNameEn, request.NationalNumber ?? string.Empty,
            request.Grade, request.Class, request.DateOfBirth,
            request.Address, request.ParentName, request.ParentPhone,
            request.RouteId, request.PickupStopId,
            request.Latitude, request.Longitude, request.HomeArea, request.HomeStreet, request.HomeBuildingNumber);
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new DeleteStudentCommand(id), cancellationToken);
        return result.IsSuccess ? NoContent() : NotFound(new { error = result.Error });
    }

    /// <summary>
    /// Mobile-app prefetch — given a scanned student-QR token, returns
    /// whether it's been registered and (if yes) which student it belongs
    /// to. Drives the parent app's "Register child" vs "Already registered"
    /// branching. Anonymous: the token itself is the credential.
    /// </summary>
    [HttpGet("registration-token/{token}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetRegistrationToken(string token, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetStudentRegistrationTokenQuery(token), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    /// <summary>
    /// Parent-app submit — first time scanning a child's QR. Creates the
    /// Student row, links to the caller's Parent record, and binds the QR
    /// so subsequent driver/assistant scans resolve to this student.
    /// </summary>
    [HttpPost("register-from-qr")]
    [Authorize(Roles = "Parent")]
    public async Task<IActionResult> RegisterFromQr([FromBody] RegisterStudentFromQrRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new RegisterStudentFromQrCommand(
                request.Token, request.FullName, request.Grade, request.Class,
                request.NationalNumber, request.HomeArea, request.HomeStreet,
                request.HomeBuildingNumber, request.Latitude, request.Longitude),
            cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Driver/assistant scans a student QR during a live trip — flips the
    /// student's StudentTrip state on that trip and writes Attendance.
    /// First scan = boarded, second scan = dropoff, third+ scan = no-op.
    /// </summary>
    [HttpPost("scan")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> Scan([FromBody] ScanStudentQrRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new ScanStudentQrCommand(request.Token, request.TripId), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }
}

public record CreateStudentRequest(
    string FullName, string? FullNameEn, string? NationalNumber,
    string Grade, string? Class, DateOnly? DateOfBirth, string? Address,
    string ParentName, string ParentPhone, Guid? ParentId, Guid? RouteId, Guid? PickupStopId,
    double? Latitude, double? Longitude, string? HomeArea, string? HomeStreet, string? HomeBuildingNumber);

public record UpdateStudentRequest(
    string FullName, string? FullNameEn, string? NationalNumber,
    string Grade, string? Class, DateOnly? DateOfBirth, string? Address,
    string ParentName, string ParentPhone, Guid? RouteId, Guid? PickupStopId,
    double? Latitude, double? Longitude, string? HomeArea, string? HomeStreet, string? HomeBuildingNumber);

public record RegisterStudentFromQrRequest(
    string Token, string FullName, string Grade, string? Class,
    string? NationalNumber, string? HomeArea, string? HomeStreet, string? HomeBuildingNumber,
    double? Latitude, double? Longitude);

public record ScanStudentQrRequest(string Token, Guid TripId);

public record BulkUpsertStudentsRequest(IReadOnlyList<BulkUpsertStudentRow> Rows);
