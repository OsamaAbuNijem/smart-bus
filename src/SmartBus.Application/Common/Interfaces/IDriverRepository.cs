using SmartBus.Domain.Entities;

namespace SmartBus.Application.Common.Interfaces;

public interface IDriverRepository : IGenericRepository<Driver>
{
    Task<Driver?> GetByLicenseNumberAsync(string licenseNumber, CancellationToken cancellationToken = default);
}
