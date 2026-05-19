using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Common.Interfaces;

public interface IBusRepository : IGenericRepository<Bus>
{
    Task<Bus?> GetByPlateNumberAsync(string plateNumber, CancellationToken cancellationToken = default);
    Task<Bus?> GetByQrTokenAsync(string qrToken, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Bus>> GetByStatusAsync(BusStatus status, CancellationToken cancellationToken = default);
}
