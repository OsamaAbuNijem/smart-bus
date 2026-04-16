using SmartBus.Domain.Entities;

namespace SmartBus.Application.Common.Interfaces;

public interface IAssistantRepository : IGenericRepository<Assistant>
{
    Task<Assistant?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default);
}
