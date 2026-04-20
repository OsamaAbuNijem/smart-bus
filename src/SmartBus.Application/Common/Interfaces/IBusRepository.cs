using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Common.Interfaces;

public interface IBusRepository : IGenericRepository<Bus>
{
    Task<Bus?> GetByPlateNumberAsync(string plateNumber, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Bus>> GetByStatusAsync(BusStatus status, CancellationToken cancellationToken = default);
}
