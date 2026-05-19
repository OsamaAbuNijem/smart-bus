using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Features.StudentTrips.Commands.UpdateBoardingStatus;
using TilmezBus.Application.Features.StudentTrips.Queries.GetStudentsByTrip;

namespace TilmezBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/student-trips")]
public class StudentTripsController : ControllerBase
{
    private readonly IMediator _mediator;

    public StudentTripsController(IMediator mediator) => _mediator = mediator;

    /// <summary>Get all students and their boarding status for a trip.</summary>
    [HttpGet("trips/{tripId:guid}")]
    public async Task<IActionResult> GetStudentsByTrip(Guid tripId, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetStudentsByTripQuery(tripId), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    /// <summary>Update a student's boarding status (scanned by assistant).</summary>
    [HttpPatch("boarding")]
    [Authorize(Roles = "Admin,Driver,Assistant")]
    public async Task<IActionResult> UpdateBoardingStatus([FromBody] UpdateBoardingStatusCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }
}
