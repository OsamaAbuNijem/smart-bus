using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Infrastructure.Persistence.Repositories;

public class AbsenceRequestRepository : GenericRepository<AbsenceRequest>, IAbsenceRequestRepository
{
    public AbsenceRequestRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IReadOnlyList<AbsenceRequest>> GetByStudentAsync(Guid studentId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(a => a.StudentId == studentId).OrderByDescending(a => a.Date).ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<AbsenceRequest>> GetByStatusAsync(AbsenceRequestStatus status, CancellationToken cancellationToken = default)
        => await _dbSet.Where(a => a.Status == status).ToListAsync(cancellationToken);
}
