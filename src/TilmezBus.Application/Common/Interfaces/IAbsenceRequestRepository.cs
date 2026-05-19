using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Common.Interfaces;

public interface IAbsenceRequestRepository : IGenericRepository<AbsenceRequest>
{
    Task<IReadOnlyList<AbsenceRequest>> GetByStudentAsync(Guid studentId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AbsenceRequest>> GetByStatusAsync(AbsenceRequestStatus status, CancellationToken cancellationToken = default);
}
