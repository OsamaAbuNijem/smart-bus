using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class SchoolRepository : GenericRepository<School>, ISchoolRepository
{
    public SchoolRepository(ApplicationDbContext context) : base(context) { }

    public async Task<School?> GetByContactEmailAsync(string email, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(s => s.ContactEmail == email, cancellationToken);
}
