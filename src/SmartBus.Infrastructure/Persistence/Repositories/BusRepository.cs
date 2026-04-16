using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class BusRepository : GenericRepository<Bus>, IBusRepository
{
    public BusRepository(ApplicationDbContext context) : base(context) { }

    public async Task<Bus?> GetByPlateNumberAsync(string plateNumber, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(b => b.PlateNumber == plateNumber, cancellationToken);

    public async Task<IReadOnlyList<Bus>> GetByStatusAsync(BusStatus status, CancellationToken cancellationToken = default)
        => await _dbSet.Where(b => b.Status == status).ToListAsync(cancellationToken);

    public async Task<Bus?> GetWithDriverAsync(Guid busId, CancellationToken cancellationToken = default)
        => await _dbSet.Include(b => b.Driver).FirstOrDefaultAsync(b => b.Id == busId, cancellationToken);
}
