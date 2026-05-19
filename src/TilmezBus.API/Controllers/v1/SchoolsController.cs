using System.Security.Claims;
using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Features.Schools.Commands.CreateSchool;
using TilmezBus.Application.Features.Schools.Commands.DeleteSchool;
using TilmezBus.Application.Features.Schools.Commands.ResetSchoolAdminPassword;
using TilmezBus.Application.Features.Schools.Commands.UpdateSchool;
using TilmezBus.Application.Features.Schools.Queries.GetAllSchools;
using TilmezBus.Application.Features.Schools.Queries.GetMySchool;
using TilmezBus.Application.Features.Schools.Queries.GetSchoolEmployeeQrTokens;
using TilmezBus.Application.Features.Schools.Queries.GetSchoolStudentQrTokens;
using TilmezBus.Domain.Enums;

namespace TilmezBus.API.Controllers.v1;

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
    public async Task<IActionResult> GetAll(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize   = 10,
        [FromQuery] string? name   = null,
        [FromQuery] string? city   = null,
        [FromQuery] SubscriptionType?    plan   = null,
        [FromQuery] SchoolStatusFilter?  status = null,
        CancellationToken cancellationToken = default)
        => Ok(await _mediator.Send(new GetAllSchoolsQuery(pageNumber, pageSize, name, city, plan, status), cancellationToken));

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
                PhoneNumber: request.PhoneNumber,
                AdminEmail: request.AdminEmail,
                ContactName: request.ContactName,
                SubscriptionActivationDate:  request.SubscriptionActivationDate,
                SubscriptionExpirationDate:  request.SubscriptionExpirationDate,
                SubscriptionType:            request.SubscriptionType,
                SubscriptionPrice:           request.SubscriptionPrice,
                SubscriptionPaymentStatus:   request.SubscriptionPaymentStatus,
                SubscriptionRemainingAmount: request.SubscriptionRemainingAmount,
                SubscriptionMaxStudents:     request.SubscriptionMaxStudents,
                SubscriptionMaxBuses:        request.SubscriptionMaxBuses,
                Latitude:  request.Latitude,
                Longitude: request.Longitude,
                LogoUrl:   request.LogoUrl,
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
                PhoneNumber: request.PhoneNumber,
                AdminEmail: request.AdminEmail,
                ContactName: request.ContactName,
                Latitude:  request.Latitude,
                Longitude: request.Longitude,
                LogoUrl:   request.LogoUrl),
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

    /// <summary>
    /// SuperAdmin: force-reset the school admin's password. Resolves the
    /// admin by the School.AdminEmail recorded on the school row.
    /// </summary>
    [HttpPost("{id:guid}/reset-admin-password")]
    [Authorize(Roles = "SuperAdmin")]
    public async Task<IActionResult> ResetAdminPassword(
        Guid id,
        [FromBody] ResetAdminPasswordRequest request,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new ResetSchoolAdminPasswordCommand(id, request.NewPassword),
            cancellationToken);
        return result.IsSuccess ? NoContent() : BadRequest(new { error = result.Error });
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

public record CreateSchoolRequest(string Name, string City, string PhoneNumber,
    string AdminEmail,
    DateTime SubscriptionActivationDate,
    DateTime SubscriptionExpirationDate,
    SubscriptionType SubscriptionType,
    decimal SubscriptionPrice,
    PaymentStatus SubscriptionPaymentStatus,
    decimal SubscriptionRemainingAmount,
    int SubscriptionMaxStudents = 500,
    int SubscriptionMaxBuses    = 20,
    string? ContactName = null,
    double? Latitude    = null,
    double? Longitude   = null,
    string? LogoUrl     = null,
    string AdminPassword = "Admin@123456");

public record ResetAdminPasswordRequest(string NewPassword);

public record UpdateSchoolRequest(string Name, string City, string PhoneNumber,
    string AdminEmail,
    string? ContactName = null,
    double? Latitude    = null,
    double? Longitude   = null,
    string? LogoUrl     = null);
