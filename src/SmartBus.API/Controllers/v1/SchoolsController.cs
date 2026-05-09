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
using SmartBus.Application.Features.Schools.Queries.GetSchoolEmployeeQrTokens;
using SmartBus.Application.Features.Schools.Queries.GetSchoolStudentQrTokens;
using SmartBus.Domain.Enums;

namespace SmartBus.API.Controllers.v1;

[Authorize]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class SchoolsController : ControllerBase
{
    private readonly IMediator _mediator;

    public SchoolsController(IMediator mediator) => _mediator = mediator;

    [HttpGet]
    [Authorize(Roles = "SuperAdmin")]
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
    [Authorize(Roles = "SuperAdmin")]
    public async Task<IActionResult> Create([FromBody] CreateSchoolRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new CreateSchoolCommand(
                Name: request.Name,
                City: request.City,
                ContactEmail: request.ContactEmail,
                PhoneNumber: request.PhoneNumber,
                AdminEmail: request.AdminEmail,
                Plan: request.Plan,
                MaxBuses: request.MaxBuses,
                MaxDrivers: request.MaxDrivers,
                MaxAssistants: request.MaxAssistants,
                MaxStudents: request.MaxStudents,
                Notes: request.Notes,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                AdminPassword: request.AdminPassword),
            cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : BadRequest(new { error = result.Error });
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "SuperAdmin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateSchoolRequest request, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new UpdateSchoolCommand(
                SchoolId: id,
                Name: request.Name,
                City: request.City,
                ContactEmail: request.ContactEmail,
                PhoneNumber: request.PhoneNumber,
                AdminEmail: request.AdminEmail,
                Plan: request.Plan,
                MaxBuses: request.MaxBuses,
                MaxDrivers: request.MaxDrivers,
                MaxAssistants: request.MaxAssistants,
                MaxStudents: request.MaxStudents,
                IsActive: request.IsActive,
                Notes: request.Notes,
                Latitude: request.Latitude,
                Longitude: request.Longitude),
            cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "SuperAdmin")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new DeleteSchoolCommand(id), cancellationToken);
        return result.IsSuccess ? NoContent() : NotFound(new { error = result.Error });
    }

    /// <summary>SuperAdmin: list every employee-registration QR token for a school.</summary>
    [HttpGet("{id:guid}/employee-qr-tokens")]
    [Authorize(Roles = "SuperAdmin")]
    public async Task<IActionResult> GetEmployeeQrTokens(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetSchoolEmployeeQrTokensQuery(id), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }

    /// <summary>SuperAdmin: list every student-registration QR token for a school.</summary>
    [HttpGet("{id:guid}/student-qr-tokens")]
    [Authorize(Roles = "SuperAdmin")]
    public async Task<IActionResult> GetStudentQrTokens(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetSchoolStudentQrTokensQuery(id), cancellationToken);
        return result.IsSuccess ? Ok(result.Data) : NotFound(new { error = result.Error });
    }
}

public record CreateSchoolRequest(string Name, string City, string ContactEmail, string PhoneNumber,
    string AdminEmail, PlanType Plan, int MaxBuses, int MaxDrivers, int MaxAssistants, int MaxStudents,
    string? Notes, double? Latitude = null, double? Longitude = null,
    string AdminPassword = "Admin@123456");

public record UpdateSchoolRequest(string Name, string City, string ContactEmail, string PhoneNumber,
    string AdminEmail, PlanType Plan, int MaxBuses, int MaxDrivers, int MaxAssistants, int MaxStudents,
    bool IsActive, string? Notes, double? Latitude = null, double? Longitude = null);
