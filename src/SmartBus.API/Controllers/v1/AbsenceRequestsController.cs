using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.AbsenceRequests.Commands.CancelAbsenceRequest;
using SmartBus.Application.Features.AbsenceRequests.Commands.ForceCancelAbsenceRequest;
using SmartBus.Application.Features.AbsenceRequests.Commands.SubmitAbsenceRequest;
using SmartBus.Application.Features.AbsenceRequests.Commands.UpdateAbsenceRequestStatus;
using SmartBus.Application.Features.AbsenceRequests.Queries.GetAbsenceRequestsByStudent;
using SmartBus.Application.Features.AbsenceRequests.Queries.GetPendingAbsenceRequests;

namespace SmartBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/absence-requests")]
public class AbsenceRequestsController : ControllerBase
{
    private readonly IMediator _mediator;

    public AbsenceRequestsController(IMediator mediator) => _mediator = mediator;

    /// <summary>Get all pending absence requests (admin view).</summary>
    [HttpGet("pending")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetPending([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetPendingAbsenceRequestsQuery(pageNumber, pageSize), cancellationToken));

    /// <summary>Get absence requests for a specific student.</summary>
    [HttpGet("students/{studentId:guid}")]
    public async Task<IActionResult> GetByStudent(Guid studentId, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAbsenceRequestsByStudentQuery(studentId), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    /// <summary>Submit an absence request (parent).</summary>
    [HttpPost]
    public async Task<IActionResult> Submit([FromBody] SubmitAbsenceRequestCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    /// <summary>Approve or reject an absence request (admin).</summary>
    [HttpPatch("{id:guid}/status")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateAbsenceStatusRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new UpdateAbsenceRequestStatusCommand(id, request.Status), cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Parent-side cancel: soft-deletes the absence request as long as the
    /// matching trip hasn't started yet.
    /// </summary>
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Cancel(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new CancelAbsenceRequestCommand(id), cancellationToken);
        return result.IsSuccess
            ? NoContent()
            : BadRequest(new { error = result.Error });
    }

    /// <summary>
    /// Crew-side cancel: lets the assistant / driver revert an absent flag
    /// while the trip is InProgress (e.g. the student showed up). Blocked
    /// only when the matching trip is already Completed.
    /// </summary>
    [HttpDelete("{id:guid}/force")]
    [Authorize(Roles = "Driver,Assistant,Admin")]
    public async Task<IActionResult> ForceCancel(
        Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new ForceCancelAbsenceRequestCommand(id), cancellationToken);
        return result.IsSuccess
            ? NoContent()
            : BadRequest(new { error = result.Error });
    }
}

public record UpdateAbsenceStatusRequest(SmartBus.Domain.Enums.AbsenceRequestStatus Status);
