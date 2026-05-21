using Microsoft.EntityFrameworkCore.Storage;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Infrastructure.Persistence.Repositories;

namespace TilmezBus.Infrastructure.Persistence;

public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;
    private IDbContextTransaction? _transaction;

    public IBusRepository Buses { get; }
    public IDriverRepository Drivers { get; }
    public IStudentRepository Students { get; }
    public ITripRepository Trips { get; }
    public INotificationRepository Notifications { get; }
    public IParentRepository Parents { get; }
    public IAbsenceRequestRepository AbsenceRequests { get; }
    public IStudentTripRepository StudentTrips { get; }
    public ISchoolRepository Schools { get; }

    public UnitOfWork(ApplicationDbContext context)
    {
        _context = context;
        Buses = new BusRepository(context);
        Drivers = new DriverRepository(context);
        Students = new StudentRepository(context);
        Trips = new TripRepository(context);
        Notifications = new NotificationRepository(context);
        Parents = new ParentRepository(context);
        AbsenceRequests = new AbsenceRequestRepository(context);
        StudentTrips = new StudentTripRepository(context);
        Schools = new SchoolRepository(context);
    }

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => await _context.SaveChangesAsync(cancellationToken);

    public async Task BeginTransactionAsync()
        => _transaction = await _context.Database.BeginTransactionAsync();

    public async Task CommitTransactionAsync()
    {
        if (_transaction is not null)
            await _transaction.CommitAsync();
    }

    public async Task RollbackTransactionAsync()
    {
        if (_transaction is not null)
            await _transaction.RollbackAsync();
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}
