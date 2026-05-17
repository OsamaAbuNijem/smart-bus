using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Utilities;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class AssistantRepository : GenericRepository<Assistant>, IAssistantRepository
{
    public AssistantRepository(ApplicationDbContext context) : base(context) { }

    public async Task<Assistant?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default)
    {
        // Tolerate any phone shape the caller passes (raw 9-digit "7XXXXXXXX",
        // legacy "07XXXXXXXX", canonical "+9627XXXXXXXX") and look up against
        // both canonical + legacy stored forms.
        var canonical = PhoneNumberHelper.Normalize(phoneNumber);
        var legacy    = PhoneNumberHelper.LegacyLocalForm(canonical);
        return await _dbSet.FirstOrDefaultAsync(
            a => a.PhoneNumber == canonical ||
                 (legacy != null && a.PhoneNumber == legacy),
            cancellationToken);
    }
}
