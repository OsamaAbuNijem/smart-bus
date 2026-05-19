using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Common.Interfaces;

public interface IParentRepository : IGenericRepository<Parent>
{
    Task<Parent?> GetByPhoneNumberAsync(string phoneNumber, CancellationToken cancellationToken = default);
    Task<Parent?> GetWithChildrenAsync(Guid parentId, CancellationToken cancellationToken = default);
}
