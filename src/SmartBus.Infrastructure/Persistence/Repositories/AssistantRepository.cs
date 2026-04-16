using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class AssistantRepository : GenericRepository<Assistant>, IAssistantRepository
{
    public AssistantRepository(ApplicationDbContext context) : base(context) { }

    public async Task<Assistant?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(a => a.PhoneNumber == phoneNumber, cancellationToken);
}
