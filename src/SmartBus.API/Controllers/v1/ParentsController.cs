using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Parents.Commands.CreateParent;
using SmartBus.Application.Features.Parents.Commands.DeleteParent;
using SmartBus.Application.Features.Parents.Commands.UpdateChildProfile;
using SmartBus.Application.Features.Parents.Queries.GetAllParents;
using SmartBus.Application.Features.Parents.Queries.GetParentById;
using SmartBus.Application.Features.Parents.Queries.GetStudentInfo;
using SmartBus.Application.Features.Parents.Queries.GetStudentTrips;

namespace SmartBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class ParentsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ParentsController(IMediator mediator) => _mediator = mediator;

    public record UpdateChildProfileRequest(
        string FullName,
        string Grade,
        string? Class,
        string? Notes,
        string ParentName,
        string ParentPhone);

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAll([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10, CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetAllParentsQuery(pageNumber, pageSize), cancellationToken));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetParentByIdQuery(id), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateParentCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? CreatedAtAction(nameof(GetById), new { id = result.Data }, result.Data)
            : BadRequest(new { error = result.Error });
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new DeleteParentCommand(id), cancellationToken);
        return result.IsSuccess ? NoContent() : NotFound(new { error = result.Error });
    }

    /// <summary>
    /// Parent-scoped update of a child's editable fields plus the parent's
    /// own name and phone. Used by the mobile Edit Student screen.
    /// </summary>
    [HttpPut("{parentId:guid}/students/{studentId:guid}/profile")]
    public async Task<IActionResult> UpdateChildProfile(
        Guid parentId,
        Guid studentId,
        [FromBody] UpdateChildProfileRequest request,
        CancellationToken cancellationToken)
    {
        var command = new UpdateChildProfileCommand(
            parentId,
            studentId,
            request.FullName,
            request.Grade,
            request.Class,
            request.Notes,
            request.ParentName,
            request.ParentPhone);
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? NoContent()
            : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Detail view of one of the parent's children — for the Student Info screen.
    /// </summary>
    [HttpGet("{parentId:guid}/students/{studentId:guid}")]
    public async Task<IActionResult> GetStudentInfo(
        Guid parentId,
        Guid studentId,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(
            new GetStudentInfoQuery(parentId, studentId),
            cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    /// <summary>
    /// Recent trips for one of the parent's children, with everything the
    /// parent dashboard needs (pickup/dropoff labels, bus, driver, boarding
    /// status, on-time/late/absent classification).
    /// </summary>
    [HttpGet("{parentId:guid}/students/{studentId:guid}/trips")]
    public async Task<IActionResult> GetStudentTrips(
        Guid parentId,
        Guid studentId,
        [FromQuery] int pageSize = 10,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(
            new GetStudentTripsQuery(parentId, studentId, pageSize),
            cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }
}
