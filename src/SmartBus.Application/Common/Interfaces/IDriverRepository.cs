using SmartBus.Domain.Entities;

namespace SmartBus.Application.Common.Interfaces;

public interface IDriverRepository : IGenericRepository<Driver>
{
    Task<Driver?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default);
}
