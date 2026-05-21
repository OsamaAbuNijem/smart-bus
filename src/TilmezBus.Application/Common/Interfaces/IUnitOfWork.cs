namespace TilmezBus.Application.Common.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IBusRepository Buses { get; }
    IDriverRepository Drivers { get; }
    IStudentRepository Students { get; }
    ITripRepository Trips { get; }
    INotificationRepository Notifications { get; }
    IParentRepository Parents { get; }
    IAbsenceRequestRepository AbsenceRequests { get; }
    IStudentTripRepository StudentTrips { get; }
    ISchoolRepository Schools { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}
