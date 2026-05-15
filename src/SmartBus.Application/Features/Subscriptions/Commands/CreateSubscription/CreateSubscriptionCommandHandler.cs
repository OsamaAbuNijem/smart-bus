using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Subscriptions.Commands.CreateSubscription;

public class CreateSubscriptionCommandHandler : IRequestHandler<CreateSubscriptionCommand, Result<Guid>>
{
    private readonly IApplicationDbContext _context;

    public CreateSubscriptionCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<Guid>> Handle(CreateSubscriptionCommand request, CancellationToken cancellationToken)
    {
        var schoolExists = await _context.Schools.AnyAsync(s => s.Id == request.SchoolId && !s.IsDeleted, cancellationToken);
        if (!schoolExists)
            return Result<Guid>.Failure("School not found.");

        if (request.ExpirationDate <= request.ActivationDate)
            return Result<Guid>.Failure("Expiration date must be after activation date.");

        // Enforce one-active-per-school: if the new subscription is being
        // activated, flip every other currently-active subscription for the
        // same school to inactive in the same transaction.
        if (request.IsActive)
        {
            var siblings = await _context.Subscriptions
                .Where(s => s.SchoolId == request.SchoolId && !s.IsDeleted && s.IsActive)
                .ToListAsync(cancellationToken);
            foreach (var s in siblings) s.IsActive = false;
        }

        var subscription = new Subscription
        {
            SchoolId         = request.SchoolId,
            SubscriptionType = request.SubscriptionType,
            MaxStudents      = request.MaxStudents,
            MaxBuses         = request.MaxBuses,
            ActivationDate   = request.ActivationDate,
            ExpirationDate   = request.ExpirationDate,
            IsActive         = request.IsActive,
            Price            = request.Price,
            IsPaid           = request.IsPaid,
            RemainingAmount  = request.RemainingAmount
        };
        _context.Subscriptions.Add(subscription);
        await _context.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(subscription.Id);
    }
}
