using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Common.Interfaces;

public interface ITripRepository : IGenericRepository<Trip>
{
    Task<IReadOnlyList<Trip>> GetByBusAsync(Guid busId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Trip>> GetByStatusAsync(TripStatus status, CancellationToken cancellationToken = default);
    Task<Trip?> GetActiveTrip(Guid busId, CancellationToken cancellationToken = default);
}
