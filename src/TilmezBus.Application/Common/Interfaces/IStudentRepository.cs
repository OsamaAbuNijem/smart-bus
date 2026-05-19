using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Common.Interfaces;

public interface IStudentRepository : IGenericRepository<Student>
{
    Task<IReadOnlyList<Student>> GetByRouteAsync(Guid routeId, CancellationToken cancellationToken = default);
}
