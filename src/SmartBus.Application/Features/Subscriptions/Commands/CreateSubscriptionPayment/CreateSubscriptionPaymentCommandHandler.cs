using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Subscriptions.Commands.CreateSubscriptionPayment;

public class CreateSubscriptionPaymentCommandHandler
    : IRequestHandler<CreateSubscriptionPaymentCommand, Result<Guid>>
{
    private readonly IApplicationDbContext _context;

    public CreateSubscriptionPaymentCommandHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<Guid>> Handle(CreateSubscriptionPaymentCommand request, CancellationToken cancellationToken)
    {
        var sub = await _context.Subscriptions
            .FirstOrDefaultAsync(s => s.Id == request.SubscriptionId && !s.IsDeleted, cancellationToken);
        if (sub is null) return Result<Guid>.Failure("Subscription not found.");
        if (request.Amount <= 0)
            return Result<Guid>.Failure("Payment amount must be positive.");

        // Guard against over-collection. Compute Σ existing payments first
        // (no tracker contamination — SumAsync hits SQL), then reject when
        // the sub is already fully paid OR when this payment would push
        // the running total past the subscription's price.
        var paidSoFar = await _context.SubscriptionPayments
            .Where(p => p.SubscriptionId == sub.Id && !p.IsDeleted)
            .SumAsync(p => (decimal?)p.Amount, cancellationToken) ?? 0m;
        var remaining = sub.Price - paidSoFar;

        if (remaining <= 0m)
            return Result<Guid>.Failure("Subscription is fully paid — no further payments accepted.");
        if (request.Amount > remaining)
            return Result<Guid>.Failure(
                $"Payment exceeds the remaining amount ({remaining:0.##}).");

        var payment = new SubscriptionPayment
        {
            SubscriptionId = sub.Id,
            PaymentDate    = request.PaymentDate,
            Amount         = request.Amount,
            Method         = request.Method
        };
        _context.SubscriptionPayments.Add(payment);

        var totalPaid       = paidSoFar + request.Amount;
        sub.RemainingAmount = sub.Price - totalPaid;
        sub.PaymentStatus   = DerivePaymentStatus(sub.Price, totalPaid);

        await _context.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(payment.Id);
    }

    /// <summary>
    /// Server-side single source of truth for the 3-state PaymentStatus,
    /// derived from price + total recorded payments. Mirrored client-side
    /// in subscriptions.js so the form preview matches what the server
    /// will persist.
    ///   * No payments / nothing collected   → Unpaid
    ///   * Collected meets or exceeds price  → Paid
    ///   * Otherwise (something in between)  → Partial
    /// </summary>
    internal static PaymentStatus DerivePaymentStatus(decimal price, decimal totalPaid)
    {
        if (totalPaid <= 0m) return PaymentStatus.Unpaid;
        if (price > 0m && totalPaid >= price) return PaymentStatus.Paid;
        return PaymentStatus.Partial;
    }
}
