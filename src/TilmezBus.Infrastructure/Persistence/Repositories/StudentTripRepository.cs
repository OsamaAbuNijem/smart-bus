using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Infrastructure.Persistence.Repositories;

public class StudentTripRepository : GenericRepository<StudentTrip>, IStudentTripRepository
{
    public StudentTripRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IReadOnlyList<StudentTrip>> GetByTripAsync(Guid tripId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(st => st.TripId == tripId).Include(st => st.Student).ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<StudentTrip>> GetByStudentAsync(Guid studentId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(st => st.StudentId == studentId).Include(st => st.Trip).ToListAsync(cancellationToken);

    public async Task<StudentTrip?> GetByStudentAndTripAsync(Guid studentId, Guid tripId, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(st => st.StudentId == studentId && st.TripId == tripId, cancellationToken);
}
