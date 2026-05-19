using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Common.Interfaces;

public interface IRouteRepository : IGenericRepository<Route>
{
    Task<Route?> GetWithStopsAsync(Guid routeId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Route>> GetAllWithStopsAsync(CancellationToken cancellationToken = default);
}
