using SmartBus.Domain.Entities;

namespace SmartBus.Application.Common.Interfaces;

public interface ISchoolRepository : IGenericRepository<School>
{
    Task<School?> GetByContactEmailAsync(string email, CancellationToken cancellationToken = default);
}
