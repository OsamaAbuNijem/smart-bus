using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Infrastructure.Persistence.Repositories;

public class TripRepository : GenericRepository<Trip>, ITripRepository
{
    public TripRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IReadOnlyList<Trip>> GetByBusAsync(Guid busId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(t => t.BusId == busId).ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Trip>> GetByStatusAsync(TripStatus status, CancellationToken cancellationToken = default)
        => await _dbSet.Where(t => t.Status == status).ToListAsync(cancellationToken);

    public async Task<Trip?> GetActiveTrip(Guid busId, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(t => t.BusId == busId && t.Status == TripStatus.InProgress, cancellationToken);
}
