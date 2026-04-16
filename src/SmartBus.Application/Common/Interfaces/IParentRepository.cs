using SmartBus.Domain.Entities;

namespace SmartBus.Application.Common.Interfaces;

public interface IParentRepository : IGenericRepository<Parent>
{
    Task<Parent?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default);
    Task<Parent?> GetWithChildrenAsync(Guid parentId, CancellationToken cancellationToken = default);
}
