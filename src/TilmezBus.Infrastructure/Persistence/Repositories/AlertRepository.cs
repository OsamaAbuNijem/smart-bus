using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Infrastructure.Persistence.Repositories;

public class AlertRepository : GenericRepository<Alert>, IAlertRepository
{
    public AlertRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IReadOnlyList<Alert>> GetByStatusAsync(AlertStatus status, CancellationToken cancellationToken = default)
        => await _dbSet.Where(a => a.Status == status).OrderByDescending(a => a.CreatedAt).ToListAsync(cancellationToken);
}
