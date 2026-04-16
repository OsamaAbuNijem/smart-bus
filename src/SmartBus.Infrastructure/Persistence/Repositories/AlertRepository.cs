using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class AlertRepository : GenericRepository<Alert>, IAlertRepository
{
    public AlertRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IReadOnlyList<Alert>> GetByStatusAsync(AlertStatus status, CancellationToken cancellationToken = default)
        => await _dbSet.Where(a => a.Status == status).OrderByDescending(a => a.CreatedAt).ToListAsync(cancellationToken);
}
