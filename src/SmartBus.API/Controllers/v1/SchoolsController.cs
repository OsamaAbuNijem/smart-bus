using System.Security.Claims;
using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartBus.Application.Features.Schools.Commands.CreateSchool;
using SmartBus.Application.Features.Schools.Commands.DeleteSchool;
using SmartBus.Application.Features.Schools.Commands.UpdateSchool;
using SmartBus.Application.Features.Schools.Queries.GetAllSchools;
using SmartBus.Application.Features.Schools.Queries.GetMySchool;
using SmartBus.Domain.Enums;

namespace SmartBus.API.Controllers.v1;

[Authorize(Roles = "SuperAdmin")]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class SchoolsController : ControllerBase
{
    private readonly IMediator _mediator;

    public SchoolsController(IMediator mediator) => _mediator = mediator;

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10, CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetAllSchoolsQuery(pageNumber, pageSize), cancellationToken));

    [HttpGet("current")]
    [Authorize(Roles = "Admin,SuperAdmin")]
    public async Task<IActionResult> GetCurrent(CancellationToken cancellationToken)
    {
        var email = User.FindFirstValue(ClaimTypes.Email);
        if (string.IsNullOrEmpty(email)) return Unauthorized();
        var result = await _mediator.Send(new GetMySchoolQuery(email), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateSchoolRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new CreateSchoolCommand(request.Name, request.City, request.ContactEmail, request.PhoneNumber,
                request.AdminEmail, request.Plan, request.MaxBuses, request.Notes, request.AdminPassword),
            cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateSchoolRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new UpdateSchoolCommand(id, request.Name, request.City, request.ContactEmail, request.PhoneNumber,
                request.AdminEmail, request.Plan, request.MaxBuses, request.IsActive, request.Notes),
            cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new DeleteSchoolCommand(id), cancellationToken);
        return result.IsSuccess ? NoContent() : NotFound(new { error = result.Error });
    }
}

public record CreateSchoolRequest(string Name, string City, string ContactEmail, string PhoneNumber,
    string AdminEmail, PlanType Plan, int MaxBuses, string? Notes, string AdminPassword = "Admin@123456");

public record UpdateSchoolRequest(string Name, string City, string ContactEmail, string PhoneNumber,
    string AdminEmail, PlanType Plan, int MaxBuses, bool IsActive, string? Notes);
