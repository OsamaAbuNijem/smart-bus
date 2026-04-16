using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class RouteRepository : GenericRepository<Route>, IRouteRepository
{
    public RouteRepository(ApplicationDbContext context) : base(context) { }

    public async Task<Route?> GetWithStopsAsync(Guid routeId, CancellationToken cancellationToken = default)
        => await _dbSet.Include(r => r.Stops.OrderBy(s => s.Order))
            .FirstOrDefaultAsync(r => r.Id == routeId, cancellationToken);

    public async Task<IReadOnlyList<Route>> GetAllWithStopsAsync(CancellationToken cancellationToken = default)
        => await _dbSet.Include(r => r.Stops.OrderBy(s => s.Order)).ToListAsync(cancellationToken);
}
