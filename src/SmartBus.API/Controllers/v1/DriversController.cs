using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Drivers.Commands.CreateDriver;
using SmartBus.Application.Features.Drivers.Commands.DeleteDriver;
using SmartBus.Application.Features.Drivers.Commands.UpdateDriver;
using SmartBus.Application.Features.Drivers.Commands.UpdateMyProfile;
using SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;
using SmartBus.Application.Features.Drivers.Queries.GetDriverById;
using SmartBus.Domain.Enums;

namespace SmartBus.API.Controllers.v1;

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
        => Ok(await _mediator.Send(new GetAllDriversQuery(pageNumber, pageSize, driverType), cancellationToken));

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
        var result = await _mediator.Send(command, cancellationToken);
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
    string FullName,
    string? FullNameEn,
    string PhoneNumber,
    bool IsActive = true,
    DriverType DriverType = DriverType.Driver
);
