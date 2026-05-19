using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Common.Interfaces;

public interface IAlertRepository : IGenericRepository<Alert>
{
    Task<IReadOnlyList<Alert>> GetByStatusAsync(AlertStatus status, CancellationToken cancellationToken = default);
}
