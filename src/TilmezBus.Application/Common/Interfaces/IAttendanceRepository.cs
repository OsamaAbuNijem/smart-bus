using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Common.Interfaces;

public interface IAttendanceRepository : IGenericRepository<Attendance>
{
    Task<IReadOnlyList<Attendance>> GetByStudentAsync(Guid studentId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Attendance>> GetByTripAsync(Guid tripId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Attendance>> GetByStudentAndDateRangeAsync(Guid studentId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default);
    Task<Attendance?> GetByStudentAndTripAsync(Guid studentId, Guid tripId, CancellationToken cancellationToken = default);
}
