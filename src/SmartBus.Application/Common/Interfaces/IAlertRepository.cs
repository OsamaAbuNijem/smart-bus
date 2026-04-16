using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Common.Interfaces;

public interface IAlertRepository : IGenericRepository<Alert>
{
    Task<IReadOnlyList<Alert>> GetByStatusAsync(AlertStatus status, CancellationToken cancellationToken = default);
}
