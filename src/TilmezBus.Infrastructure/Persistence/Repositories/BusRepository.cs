using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Infrastructure.Persistence.Repositories;

public class BusRepository : GenericRepository<Bus>, IBusRepository
{
    public BusRepository(ApplicationDbContext context) : base(context) { }

    public async Task<Bus?> GetByPlateNumberAsync(string plateNumber, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(b => b.PlateNumber == plateNumber, cancellationToken);

    public async Task<Bus?> GetByQrTokenAsync(string qrToken, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(b => b.QrToken == qrToken, cancellationToken);

    public async Task<IReadOnlyList<Bus>> GetByStatusAsync(BusStatus status, CancellationToken cancellationToken = default)
        => await _dbSet.Where(b => b.Status == status).ToListAsync(cancellationToken);
}
