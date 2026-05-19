using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Common.Interfaces;

public interface IAssistantRepository : IGenericRepository<Assistant>
{
    Task<Assistant?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default);
}
