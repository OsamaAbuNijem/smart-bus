using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Common.Interfaces;

public interface IStudentTripRepository : IGenericRepository<StudentTrip>
{
    Task<IReadOnlyList<StudentTrip>> GetByTripAsync(Guid tripId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<StudentTrip>> GetByStudentAsync(Guid studentId, CancellationToken cancellationToken = default);
    Task<StudentTrip?> GetByStudentAndTripAsync(Guid studentId, Guid tripId, CancellationToken cancellationToken = default);
}
