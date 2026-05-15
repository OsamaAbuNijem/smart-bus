using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;

namespace SmartBus.Infrastructure.Subscriptions;

public class ActiveSubscriptionService : IActiveSubscriptionService
{
    private readonly IApplicationDbContext _context;

    public ActiveSubscriptionService(IApplicationDbContext context) => _context = context;

    public async Task<Guid?> GetActiveSubscriptionIdAsync(Guid schoolId, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        return await _context.Subscriptions
            .Where(s => s.SchoolId == schoolId
                     && s.IsActive
                     && s.ActivationDate <= now
                     && s.ExpirationDate >= now)
            .OrderByDescending(s => s.ActivationDate)
            .Select(s => (Guid?)s.Id)
            .FirstOrDefaultAsync(cancellationToken);
    }
}
