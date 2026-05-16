using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;

namespace SmartBus.Application.Features.Subscriptions.Queries.GetSchoolSubscriptions;

public class GetSchoolSubscriptionsQueryHandler
    : IRequestHandler<GetSchoolSubscriptionsQuery, IReadOnlyList<SubscriptionDto>>
{
    private readonly IApplicationDbContext _context;

    public GetSchoolSubscriptionsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<IReadOnlyList<SubscriptionDto>> Handle(GetSchoolSubscriptionsQuery request, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        return await _context.Subscriptions
            .Where(s => s.SchoolId == request.SchoolId && !s.IsDeleted)
            .OrderByDescending(s => s.ActivationDate)
            .Select(s => new SubscriptionDto(
                s.Id,
                s.SchoolId,
                s.SubscriptionType,
                s.MaxStudents,
                s.MaxBuses,
                s.ActivationDate,
                s.ExpirationDate,
                s.IsActive,
                s.IsActive && s.ActivationDate <= now && s.ExpirationDate >= now,
                s.Price,
                s.PaymentStatus,
                s.RemainingAmount,
                s.CreatedAt))
            .ToListAsync(cancellationToken);
    }
}
