using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class DriverRepository : GenericRepository<Driver>, IDriverRepository
{
    public DriverRepository(ApplicationDbContext context) : base(context) { }

    public async Task<Driver?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(d => d.PhoneNumber == phoneNumber, cancellationToken);
}
