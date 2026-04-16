using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class ParentRepository : GenericRepository<Parent>, IParentRepository
{
    public ParentRepository(ApplicationDbContext context) : base(context) { }

    public async Task<Parent?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(p => p.PhoneNumber == phoneNumber, cancellationToken);

    public async Task<Parent?> GetWithChildrenAsync(Guid parentId, CancellationToken cancellationToken = default)
        => await _dbSet.Include(p => p.Children).FirstOrDefaultAsync(p => p.Id == parentId, cancellationToken);
}
