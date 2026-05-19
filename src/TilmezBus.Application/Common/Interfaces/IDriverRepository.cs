using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Common.Interfaces;

public interface IDriverRepository : IGenericRepository<Driver>
{
    Task<Driver?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default);
}
