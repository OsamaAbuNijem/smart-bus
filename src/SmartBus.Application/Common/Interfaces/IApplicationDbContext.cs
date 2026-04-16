using Microsoft.EntityFrameworkCore;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<Bus> Buses { get; }
    DbSet<Driver> Drivers { get; }
    DbSet<Assistant> Assistants { get; }
    DbSet<Route> Routes { get; }
    DbSet<Stop> Stops { get; }
    DbSet<Student> Students { get; }
    DbSet<Parent> Parents { get; }
    DbSet<Trip> Trips { get; }
    DbSet<StudentTrip> StudentTrips { get; }
    DbSet<Attendance> Attendances { get; }
    DbSet<AbsenceRequest> AbsenceRequests { get; }
    DbSet<BusLocation> BusLocations { get; }
    DbSet<Notification> Notifications { get; }
    DbSet<Alert> Alerts { get; }
    DbSet<EmergencyContact> EmergencyContacts { get; }
    DbSet<StudentAllergy> StudentAllergies { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
