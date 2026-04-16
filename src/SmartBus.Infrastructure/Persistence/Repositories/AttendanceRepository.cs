using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class AttendanceRepository : GenericRepository<Attendance>, IAttendanceRepository
{
    public AttendanceRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IReadOnlyList<Attendance>> GetByStudentAsync(Guid studentId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(a => a.StudentId == studentId).ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Attendance>> GetByTripAsync(Guid tripId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(a => a.TripId == tripId).ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Attendance>> GetByStudentAndDateRangeAsync(Guid studentId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default)
        => await _dbSet.Where(a => a.StudentId == studentId && a.Date >= from && a.Date <= to).ToListAsync(cancellationToken);

    public async Task<Attendance?> GetByStudentAndTripAsync(Guid studentId, Guid tripId, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(a => a.StudentId == studentId && a.TripId == tripId, cancellationToken);
}
