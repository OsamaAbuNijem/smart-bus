using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Buses.Commands.CreateBus;
using SmartBus.Application.Features.Buses.Commands.UpdateBusLocation;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;
using SmartBus.Application.Features.Buses.Queries.GetBusById;

namespace SmartBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class BusesController : ControllerBase
{
    private readonly IMediator _mediator;

    public BusesController(IMediator mediator)
        => _mediator = mediator;

    /// <summary>Get all buses (paginated).</summary>
    [HttpGet]
    [ProducesResponseType(typeof(GetAllBusesQuery), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10, CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(new GetAllBusesQuery(pageNumber, pageSize), cancellationToken);
        return Ok(result);
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
    public async Task<IActionResult> Create([FromBody] CreateBusCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? CreatedAtAction(nameof(GetById), new { id = result.Data }, result.Data)
            : BadRequest(new { error = result.Error });
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
