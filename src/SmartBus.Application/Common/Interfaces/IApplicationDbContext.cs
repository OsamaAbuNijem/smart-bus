using Microsoft.EntityFrameworkCore;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<Bus> Buses { get; }
    DbSet<Driver> Drivers { get; }
    DbSet<Route> Routes { get; }
    DbSet<Stop> Stops { get; }
    DbSet<Student> Students { get; }
    DbSet<Trip> Trips { get; }
    DbSet<BusLocation> BusLocations { get; }
    DbSet<Notification> Notifications { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
