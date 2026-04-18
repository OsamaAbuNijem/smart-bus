using System.Security.Claims;
using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Schools.Queries.GetMySchool;
using SmartBus.Application.Features.Students.Commands.CreateStudent;
using SmartBus.Application.Features.Students.Commands.DeleteStudent;
using SmartBus.Application.Features.Students.Commands.UpdateStudent;
using SmartBus.Application.Features.Students.Queries.GetAllStudents;
using SmartBus.Application.Features.Students.Queries.GetStudentById;

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
    public async Task<IActionResult> GetAll([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10, [FromQuery] Guid? routeId = null, CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetAllStudentsQuery(pageNumber, pageSize, routeId), cancellationToken));

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
            request.FullName, request.FullNameEn, request.Grade, request.Class, request.DateOfBirth,
            request.Address, request.ParentName, request.ParentNameEn, request.ParentPhone,
            request.ParentId, request.RouteId, request.PickupStopId,
            request.Latitude, request.Longitude, request.HomeArea, request.HomeStreet, request.HomeBuildingNumber);

        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? CreatedAtAction(nameof(GetById), new { id = result.Data }, result.Data)
            : BadRequest(new { error = result.Error });
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateStudentRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateStudentCommand(
            id, request.FullName, request.FullNameEn, request.Grade, request.Class, request.DateOfBirth,
            request.Address, request.ParentName, request.ParentNameEn, request.ParentPhone,
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
}

public record CreateStudentRequest(
    string FullName, string? FullNameEn, string Grade, string? Class, DateOnly? DateOfBirth, string? Address,
    string ParentName, string? ParentNameEn, string ParentPhone, Guid? ParentId, Guid? RouteId, Guid? PickupStopId,
    double? Latitude, double? Longitude, string? HomeArea, string? HomeStreet, string? HomeBuildingNumber);

public record UpdateStudentRequest(
    string FullName, string? FullNameEn, string Grade, string? Class, DateOnly? DateOfBirth, string? Address,
    string ParentName, string? ParentNameEn, string ParentPhone, Guid? RouteId, Guid? PickupStopId,
    double? Latitude, double? Longitude, string? HomeArea, string? HomeStreet, string? HomeBuildingNumber);
