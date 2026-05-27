using Microsoft.EntityFrameworkCore;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<Bus> Buses { get; }
    DbSet<Driver> Drivers { get; }
    DbSet<Student> Students { get; }
    DbSet<Parent> Parents { get; }
    DbSet<Trip> Trips { get; }
    DbSet<StudentTrip> StudentTrips { get; }
    DbSet<AbsenceRequest> AbsenceRequests { get; }
    DbSet<BusLocation> BusLocations { get; }
    DbSet<Notification> Notifications { get; }
    DbSet<NotificationTemplate> NotificationTemplates { get; }
    DbSet<School> Schools { get; }
    DbSet<Subscription> Subscriptions { get; }
    DbSet<SubscriptionStudent> SubscriptionStudents { get; }
    DbSet<SubscriptionPayment> SubscriptionPayments { get; }
    DbSet<SuperAdminBroadcast> SuperAdminBroadcasts { get; }
    DbSet<StudentQrToken>  StudentQrTokens  { get; }
    DbSet<UserDeviceToken> UserDeviceTokens { get; }
    DbSet<DemoRequest> DemoRequests { get; }
    DbSet<RefreshToken> RefreshTokens { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
