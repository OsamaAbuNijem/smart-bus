using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Utilities;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Infrastructure.Persistence.Repositories;

public class ParentRepository : GenericRepository<Parent>, IParentRepository
{
    public ParentRepository(ApplicationDbContext context) : base(context) { }

    public async Task<Parent?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default)
    {
        // Tolerate either canonical "+9627XXXXXXXX" or legacy "07XXXXXXXX" rows
        // during the transition window. Whatever the caller types is normalised
        // first so partial / international forms also resolve correctly.
        var canonical = PhoneNumberHelper.Normalize(phoneNumber);
        var legacy = PhoneNumberHelper.LegacyLocalForm(canonical);
        return await _dbSet.FirstOrDefaultAsync(
            p => p.PhoneNumber == canonical ||
                 (legacy != null && p.PhoneNumber == legacy),
            cancellationToken);
    }

    public async Task<Parent?> GetWithChildrenAsync(Guid parentId, CancellationToken cancellationToken = default)
        => await _dbSet.Include(p => p.Children).FirstOrDefaultAsync(p => p.Id == parentId, cancellationToken);
}
