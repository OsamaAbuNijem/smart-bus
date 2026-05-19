using Microsoft.EntityFrameworkCore;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Common.Interfaces;

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
    DbSet<NotificationTemplate> NotificationTemplates { get; }
    DbSet<Alert> Alerts { get; }
    DbSet<EmergencyContact> EmergencyContacts { get; }
    DbSet<StudentAllergy> StudentAllergies { get; }
    DbSet<School> Schools { get; }
    DbSet<Subscription> Subscriptions { get; }
    DbSet<SubscriptionStudent> SubscriptionStudents { get; }
    DbSet<SubscriptionPayment> SubscriptionPayments { get; }
    DbSet<SuperAdminBroadcast> SuperAdminBroadcasts { get; }
    DbSet<BusSchedule> BusSchedules { get; }
    DbSet<BusScheduleStudent> BusScheduleStudents { get; }
    DbSet<EmployeeQrToken> EmployeeQrTokens { get; }
    DbSet<StudentQrToken>  StudentQrTokens  { get; }
    DbSet<UserDeviceToken> UserDeviceTokens { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
