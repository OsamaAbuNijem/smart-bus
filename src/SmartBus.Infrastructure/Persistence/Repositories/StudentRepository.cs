using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class StudentRepository : GenericRepository<Student>, IStudentRepository
{
    public StudentRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IReadOnlyList<Student>> GetByRouteAsync(Guid routeId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(s => s.RouteId == routeId).ToListAsync(cancellationToken);
}
