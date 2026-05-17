using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Utilities;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class DriverRepository : GenericRepository<Driver>, IDriverRepository
{
    public DriverRepository(ApplicationDbContext context) : base(context) { }

    public async Task<Driver?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default)
    {
        // Tolerate any phone shape the caller passes (raw 9-digit "7XXXXXXXX",
        // legacy "07XXXXXXXX", canonical "+9627XXXXXXXX") and look up against
        // both canonical + legacy stored forms — historical seed data uses one
        // shape, freshly-created rows may use another.
        var canonical = PhoneNumberHelper.Normalize(phoneNumber);
        var legacy    = PhoneNumberHelper.LegacyLocalForm(canonical);
        return await _dbSet.FirstOrDefaultAsync(
            d => d.PhoneNumber == canonical ||
                 (legacy != null && d.PhoneNumber == legacy),
            cancellationToken);
    }
}
