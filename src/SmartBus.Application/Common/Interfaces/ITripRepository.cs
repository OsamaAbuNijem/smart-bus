using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Common.Interfaces;

public interface ITripRepository : IGenericRepository<Trip>
{
    Task<IReadOnlyList<Trip>> GetByBusAsync(Guid busId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Trip>> GetByStatusAsync(TripStatus status, CancellationToken cancellationToken = default);
    Task<Trip?> GetActiveTrip(Guid busId, CancellationToken cancellationToken = default);
}
