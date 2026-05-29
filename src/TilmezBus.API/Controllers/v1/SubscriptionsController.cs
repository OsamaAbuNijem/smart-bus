using Asp.Versioning;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TilmezBus.Application.Features.Subscriptions.Commands.CreateSubscription;
using TilmezBus.Application.Features.Subscriptions.Commands.CreateSubscriptionPayment;
using TilmezBus.Application.Features.Subscriptions.Commands.UpdateSubscription;
using TilmezBus.Application.Features.Subscriptions.Queries.GetSchoolSubscriptions;
using TilmezBus.Application.Features.Subscriptions.Queries.GetSubscriptionPayments;
using TilmezBus.Domain.Enums;

namespace TilmezBus.API.Controllers.v1;

[Authorize(Roles = "SuperAdmin")]
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}")]
public class SubscriptionsController : ControllerBase
{
    private readonly IMediator _mediator;

    public SubscriptionsController(IMediator mediator) => _mediator = mediator;

    /// <summary>List every subscription for a school (newest activation first).</summary>
    [HttpGet("schools/{schoolId:guid}/subscriptions")]
    public async Task<IActionResult> ListForSchool(Guid schoolId, CancellationToken cancellationToken)
        => Ok(await _mediator.Send(new GetSchoolSubscriptionsQuery(schoolId), cancellationToken));

    /// <summary>Create a new subscription. If IsActive is true, any existing active sub for the same school is auto-deactivated.</summary>
    [HttpPost("schools/{schoolId:guid}/subscriptions")]
    public async Task<IActionResult> Create(Guid schoolId, [FromBody] SubscriptionRequest request, CancellationToken cancellationToken)
    {
        var command = new CreateSubscriptionCommand(
            SchoolId:         schoolId,
            SubscriptionType: request.SubscriptionType,
            MaxStudents:      request.MaxStudents,
            MaxBuses:         request.MaxBuses,
            ActivationDate:   request.ActivationDate,
            ExpirationDate:   request.ExpirationDate,
            IsActive:         request.IsActive,
            Price:            request.Price,
            PaymentStatus:    request.PaymentStatus,
            RemainingAmount:  request.RemainingAmount,
            EnableQr:         request.EnableQr,
            EnableNfc:        request.EnableNfc);
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? Ok(new { id = result.Data })
            : BadRequest(new { error = result.Error });
    }

    /// <summary>Update a subscription in-place. Activating it auto-deactivates any other active sub on the same school.</summary>
    [HttpPut("subscriptions/{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] SubscriptionRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateSubscriptionCommand(
            SubscriptionId:   id,
            SubscriptionType: request.SubscriptionType,
            MaxStudents:      request.MaxStudents,
            MaxBuses:         request.MaxBuses,
            ActivationDate:   request.ActivationDate,
            ExpirationDate:   request.ExpirationDate,
            IsActive:         request.IsActive,
            Price:            request.Price,
            PaymentStatus:    request.PaymentStatus,
            RemainingAmount:  request.RemainingAmount,
            EnableQr:         request.EnableQr,
            EnableNfc:        request.EnableNfc);
        var result = await _mediator.Send(command, cancellationToken);
        return result.IsSuccess
            ? NoContent()
            : BadRequest(new { error = result.Error });
    }

    /// <summary>List every payment instalment recorded against a subscription, newest first.</summary>
    [HttpGet("subscriptions/{id:guid}/payments")]
    public async Task<IActionResult> ListPayments(Guid id, CancellationToken cancellationToken)
        => Ok(await _mediator.Send(new GetSubscriptionPaymentsQuery(id), cancellationToken));

    /// <summary>Record a single payment instalment (cash or transfer) against a subscription.</summary>
    [HttpPost("subscriptions/{id:guid}/payments")]
    public async Task<IActionResult> CreatePayment(
        Guid id,
        [FromBody] SubscriptionPaymentRequest request,
        CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(
            new CreateSubscriptionPaymentCommand(
                SubscriptionId: id,
                PaymentDate:    request.PaymentDate,
                Amount:         request.Amount,
                Method:         request.Method),
            cancellationToken);
        return result.IsSuccess
            ? Ok(new { id = result.Data })
            : BadRequest(new { error = result.Error });
    }
}

public record SubscriptionRequest(
    SubscriptionType SubscriptionType,
    int MaxStudents,
    int MaxBuses,
    DateTime ActivationDate,
    DateTime ExpirationDate,
    bool IsActive,
    decimal Price,
    PaymentStatus PaymentStatus,
    decimal RemainingAmount,
    bool EnableQr  = true,
    bool EnableNfc = true);

public record SubscriptionPaymentRequest(
    DateTime      PaymentDate,
    decimal       Amount,
    PaymentMethod Method);
