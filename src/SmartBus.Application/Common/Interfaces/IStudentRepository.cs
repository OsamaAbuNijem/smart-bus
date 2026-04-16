using SmartBus.Domain.Entities;

namespace SmartBus.Application.Common.Interfaces;

public interface IStudentRepository : IGenericRepository<Student>
{
    Task<IReadOnlyList<Student>> GetByRouteAsync(Guid routeId, CancellationToken cancellationToken = default);
}
