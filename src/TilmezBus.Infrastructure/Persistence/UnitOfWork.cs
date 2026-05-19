using Microsoft.EntityFrameworkCore.Storage;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Infrastructure.Persistence.Repositories;

namespace TilmezBus.Infrastructure.Persistence;

public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;
    private IDbContextTransaction? _transaction;

    public IBusRepository Buses { get; }
    public IRouteRepository Routes { get; }
    public IDriverRepository Drivers { get; }
    public IStudentRepository Students { get; }
    public ITripRepository Trips { get; }
    public INotificationRepository Notifications { get; }
    public IParentRepository Parents { get; }
    public IAssistantRepository Assistants { get; }
    public IAttendanceRepository Attendances { get; }
    public IAbsenceRequestRepository AbsenceRequests { get; }
    public IStudentTripRepository StudentTrips { get; }
    public IAlertRepository Alerts { get; }
    public ISchoolRepository Schools { get; }

    public UnitOfWork(ApplicationDbContext context)
    {
        _context = context;
        Buses = new BusRepository(context);
        Routes = new RouteRepository(context);
        Drivers = new DriverRepository(context);
        Students = new StudentRepository(context);
        Trips = new TripRepository(context);
        Notifications = new NotificationRepository(context);
        Parents = new ParentRepository(context);
        Assistants = new AssistantRepository(context);
        Attendances = new AttendanceRepository(context);
        AbsenceRequests = new AbsenceRequestRepository(context);
        StudentTrips = new StudentTripRepository(context);
        Alerts = new AlertRepository(context);
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
