using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;

namespace SmartBus.Application.Features.Subscriptions.Queries.GetSubscriptionPayments;

public class GetSubscriptionPaymentsQueryHandler
    : IRequestHandler<GetSubscriptionPaymentsQuery, IReadOnlyList<SubscriptionPaymentDto>>
{
    private readonly IApplicationDbContext _context;

    public GetSubscriptionPaymentsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<IReadOnlyList<SubscriptionPaymentDto>> Handle(GetSubscriptionPaymentsQuery request, CancellationToken cancellationToken)
    {
        return await _context.SubscriptionPayments
            .Where(p => p.SubscriptionId == request.SubscriptionId)
            .OrderByDescending(p => p.PaymentDate)
            .ThenByDescending(p => p.CreatedAt)
            .Select(p => new SubscriptionPaymentDto(
                p.Id,
                p.SubscriptionId,
                p.PaymentDate,
                p.Amount,
                p.Method,
                p.CreatedAt))
            .ToListAsync(cancellationToken);
    }
}
