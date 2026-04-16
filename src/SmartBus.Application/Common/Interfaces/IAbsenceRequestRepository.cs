using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Common.Interfaces;

public interface IAbsenceRequestRepository : IGenericRepository<AbsenceRequest>
{
    Task<IReadOnlyList<AbsenceRequest>> GetByStudentAsync(Guid studentId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AbsenceRequest>> GetByStatusAsync(AbsenceRequestStatus status, CancellationToken cancellationToken = default);
}
