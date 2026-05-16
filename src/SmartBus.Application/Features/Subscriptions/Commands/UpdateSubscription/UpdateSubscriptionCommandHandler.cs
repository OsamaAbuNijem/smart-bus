using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Subscriptions.Commands.CreateSubscriptionPayment;

namespace SmartBus.Application.Features.Subscriptions.Commands.UpdateSubscription;

public class UpdateSubscriptionCommandHandler : IRequestHandler<UpdateSubscriptionCommand, Result>
{
    private readonly IApplicationDbContext _context;

    public UpdateSubscriptionCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result> Handle(UpdateSubscriptionCommand request, CancellationToken cancellationToken)
    {
        var subscription = await _context.Subscriptions
            .FirstOrDefaultAsync(s => s.Id == request.SubscriptionId && !s.IsDeleted, cancellationToken);
        if (subscription is null) return Result.Failure("Subscription not found.");

        if (request.ExpirationDate <= request.ActivationDate)
            return Result.Failure("Expiration date must be after activation date.");

        // If this update activates the subscription, deactivate every other
        // active sibling on the same school so the one-active-per-school
        // invariant holds. Skip when we're not flipping IsActive on.
        if (request.IsActive && !subscription.IsActive)
        {
            var siblings = await _context.Subscriptions
                .Where(s => s.SchoolId == subscription.SchoolId
                         && !s.IsDeleted && s.IsActive
                         && s.Id != subscription.Id)
                .ToListAsync(cancellationToken);
            foreach (var s in siblings) s.IsActive = false;
        }

        subscription.SubscriptionType = request.SubscriptionType;
        subscription.MaxStudents      = request.MaxStudents;
        subscription.MaxBuses         = request.MaxBuses;
        subscription.ActivationDate   = request.ActivationDate;
        subscription.ExpirationDate   = request.ExpirationDate;
        subscription.IsActive         = request.IsActive;
        subscription.Price = request.Price;

        // RemainingAmount + PaymentStatus are server-derived from the
        // payments log so the client's values are ignored. A price edit
        // immediately re-balances both fields.
        var paidSoFar = await _context.SubscriptionPayments
            .Where(p => p.SubscriptionId == subscription.Id && !p.IsDeleted)
            .SumAsync(p => (decimal?)p.Amount, cancellationToken) ?? 0m;
        subscription.RemainingAmount = request.Price - paidSoFar;
        subscription.PaymentStatus   = CreateSubscriptionPaymentCommandHandler
            .DerivePaymentStatus(request.Price, paidSoFar);

        await _context.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
