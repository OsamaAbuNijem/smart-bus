using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Entities;
using TilmezBus.Infrastructure.Identity;

namespace TilmezBus.Infrastructure.Persistence;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser>, IApplicationDbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<Bus> Buses => Set<Bus>();
    public DbSet<Driver> Drivers => Set<Driver>();
    public DbSet<Student> Students => Set<Student>();
    public DbSet<Parent> Parents => Set<Parent>();
    public DbSet<Trip> Trips => Set<Trip>();
    public DbSet<StudentTrip> StudentTrips => Set<StudentTrip>();
    public DbSet<AbsenceRequest> AbsenceRequests => Set<AbsenceRequest>();
    public DbSet<BusLocation> BusLocations => Set<BusLocation>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<NotificationTemplate> NotificationTemplates =>
        Set<NotificationTemplate>();
    public DbSet<School> Schools => Set<School>();
    public DbSet<Subscription> Subscriptions => Set<Subscription>();
    public DbSet<SubscriptionStudent> SubscriptionStudents => Set<SubscriptionStudent>();
    public DbSet<SubscriptionPayment> SubscriptionPayments => Set<SubscriptionPayment>();
    public DbSet<SuperAdminBroadcast> SuperAdminBroadcasts => Set<SuperAdminBroadcast>();
    public DbSet<StudentQrToken>  StudentQrTokens  => Set<StudentQrToken>();
    public DbSet<UserDeviceToken> UserDeviceTokens => Set<UserDeviceToken>();
    public DbSet<DemoRequest> DemoRequests => Set<DemoRequest>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        builder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        // Soft-delete filters
        builder.Entity<Bus>().HasQueryFilter(b => !b.IsDeleted);
        builder.Entity<BusLocation>().HasQueryFilter(l => !l.IsDeleted);
        builder.Entity<Driver>().HasQueryFilter(d => !d.IsDeleted);
        builder.Entity<Student>().HasQueryFilter(s => !s.IsDeleted);
        builder.Entity<Parent>().HasQueryFilter(p => !p.IsDeleted);
        builder.Entity<Trip>().HasQueryFilter(t => !t.IsDeleted);
        builder.Entity<StudentTrip>().HasQueryFilter(st => !st.IsDeleted);
        builder.Entity<AbsenceRequest>().HasQueryFilter(a => !a.IsDeleted);
        builder.Entity<Notification>().HasQueryFilter(n => !n.IsDeleted);
        builder.Entity<NotificationTemplate>().HasQueryFilter(t => !t.IsDeleted);
        // One template per (Type, LanguageCode) — soft-deleted rows allowed
        // so we can keep history when an admin re-edits copy.
        builder.Entity<NotificationTemplate>()
            .HasIndex(t => new { t.Type, t.LanguageCode })
            .IsUnique()
            .HasFilter("\"IsDeleted\" = false");
        builder.Entity<School>().HasQueryFilter(s => !s.IsDeleted);
        builder.Entity<DemoRequest>().HasQueryFilter(d => !d.IsDeleted);
        builder.Entity<DemoRequest>().Property(d => d.SchoolName).HasMaxLength(200);
        builder.Entity<DemoRequest>().Property(d => d.ContactName).HasMaxLength(200);
        builder.Entity<DemoRequest>().Property(d => d.Email).HasMaxLength(256);
        builder.Entity<DemoRequest>().Property(d => d.PhoneNumber).HasMaxLength(40);
        builder.Entity<DemoRequest>().Property(d => d.Notes).HasMaxLength(2000);
        // SuperAdmin queue is always read newest-first and may filter by status,
        // so a composite index keeps the list page snappy as the table grows.
        builder.Entity<DemoRequest>()
            .HasIndex(d => new { d.Status, d.CreatedAt });

        // ── Subscriptions ──────────────────────────────────────────────────
        builder.Entity<Subscription>().HasQueryFilter(s => !s.IsDeleted);
        // Mirror the Subscription filter so the required relationship from
        // SubscriptionPayment doesn't trip EF Core's "missing matching filter"
        // warning and so deleted subscriptions don't surface their payments.
        builder.Entity<SubscriptionPayment>().HasQueryFilter(p => !p.IsDeleted && !p.Subscription!.IsDeleted);

        builder.Entity<Subscription>()
            .HasOne(s => s.School)
            .WithMany()
            .HasForeignKey(s => s.SchoolId)
            .OnDelete(DeleteBehavior.Cascade);

        // Lookup index for the "active subscription for this school" query.
        builder.Entity<Subscription>()
            .HasIndex(s => new { s.SchoolId, s.IsActive, s.ActivationDate, s.ExpirationDate });

        builder.Entity<Subscription>().Property(s => s.Price).HasColumnType("numeric(12,2)");
        builder.Entity<Subscription>().Property(s => s.RemainingAmount).HasColumnType("numeric(12,2)");

        // Subscription ↔ Student join. Composite key. Soft-delete filter
        // tracks the student row (subscription rows themselves aren't soft-deleted on the link).
        builder.Entity<SubscriptionStudent>()
            .HasKey(x => new { x.SubscriptionId, x.StudentId });

        builder.Entity<SubscriptionStudent>()
            .HasQueryFilter(x => !x.Student!.IsDeleted && !x.Subscription!.IsDeleted);

        builder.Entity<SubscriptionStudent>()
            .HasOne(x => x.Subscription)
            .WithMany(s => s.StudentLinks)
            .HasForeignKey(x => x.SubscriptionId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<SubscriptionStudent>()
            .HasOne(x => x.Student)
            .WithMany()
            .HasForeignKey(x => x.StudentId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<SubscriptionStudent>()
            .HasIndex(x => x.StudentId);

        builder.Entity<StudentQrToken>().HasQueryFilter(t => !t.IsDeleted);

        builder.Entity<StudentQrToken>()
            .HasIndex(t => t.Token)
            .IsUnique()
            .HasFilter("\"IsDeleted\" = false");

        builder.Entity<StudentQrToken>()
            .HasIndex(t => new { t.SchoolId, t.IsRegistered });

        builder.Entity<StudentQrToken>()
            .HasOne(t => t.School)
            .WithMany()
            .HasForeignKey(t => t.SchoolId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<StudentQrToken>()
            .HasOne(t => t.Student)
            .WithMany()
            .HasForeignKey(t => t.StudentId)
            .OnDelete(DeleteBehavior.NoAction);


        // Bus → BusLocation: history (one-to-many via BusLocation.BusId)
        builder.Entity<Bus>()
            .HasMany(b => b.BusLocations)
            .WithOne(l => l.Bus)
            .HasForeignKey(l => l.BusId)
            .OnDelete(DeleteBehavior.Cascade);

        // Bus → LastLocation: pointer to latest record (FK on Bus side, NoAction to avoid cycle with Cascade on BusLocations)
        builder.Entity<Bus>()
            .HasOne(b => b.LastLocation)
            .WithMany()
            .HasForeignKey(b => b.LastLocationId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.NoAction);

        // Tenant scope: Bus / Driver belong to a school. Nullable
        // FK so existing rows (created before the column existed) survive
        // the migration; new rows always have a SchoolId.
        builder.Entity<Bus>()
            .HasOne(b => b.School)
            .WithMany()
            .HasForeignKey(b => b.SchoolId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Driver>()
            .HasOne(d => d.School)
            .WithMany()
            .HasForeignKey(d => d.SchoolId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Restrict);
        builder.Entity<Bus>()    .HasIndex(b => b.SchoolId);
        builder.Entity<Driver>() .HasIndex(d => d.SchoolId);

        // StudentTrip composite index
        builder.Entity<StudentTrip>()
            .HasIndex(st => new { st.StudentId, st.TripId })
            .IsUnique();

        // ── Hot-path indexes (based on query handler scan) ────────────────
        // List queries sort by CreatedAt DESC with IsDeleted=false predicate:
        builder.Entity<Bus>()    .HasIndex(b => new { b.IsDeleted, b.CreatedAt });
        builder.Entity<Driver>() .HasIndex(d => new { d.IsDeleted, d.CreatedAt });
        builder.Entity<Student>().HasIndex(s => new { s.IsDeleted, s.CreatedAt });
        builder.Entity<Trip>()   .HasIndex(t => new { t.IsDeleted, t.ScheduledDeparture });

        // Trip filters by status + date (used by the Trips page filter bar):
        builder.Entity<Trip>().HasIndex(t => new { t.Status, t.ScheduledDeparture });

        // Driver filtering by type:
        builder.Entity<Driver>().HasIndex(d => new { d.DriverType, d.IsDeleted });

        // Unique phone per active (non-deleted) driver:
        builder.Entity<Driver>()
            .HasIndex(d => d.PhoneNumber)
            .IsUnique()
            .HasFilter("\"IsDeleted\" = false");

        // Unique national number per active student (blank rows excluded for backfill safety):
        builder.Entity<Student>()
            .HasIndex(s => s.NationalNumber)
            .IsUnique()
            .HasFilter("\"IsDeleted\" = false AND \"NationalNumber\" <> ''");

        // Unique phone per active parent (so siblings resolve to one Parent row):
        builder.Entity<Parent>()
            .HasIndex(p => p.PhoneNumber)
            .IsUnique()
            .HasFilter("\"IsDeleted\" = false");

        // Latest-location lookup on BusLocation:
        builder.Entity<BusLocation>().HasIndex(l => new { l.BusId, l.Timestamp });

        // FCM device tokens — one user can have many; (UserId, Token) unique
        // so re-registering an existing device is a true upsert. Token is
        // capped at 512 chars (FCM tokens are ~163 today; cap with headroom)
        // so the column can participate in a unique index.
        builder.Entity<UserDeviceToken>().HasQueryFilter(t => !t.IsDeleted);
        builder.Entity<UserDeviceToken>().Property(t => t.Token).HasMaxLength(512).IsRequired();
        builder.Entity<UserDeviceToken>().Property(t => t.Platform).HasMaxLength(16).IsRequired();
        builder.Entity<UserDeviceToken>()
            .HasIndex(t => new { t.UserId, t.Token })
            .IsUnique()
            .HasFilter("\"IsDeleted\" = false");

        // Refresh tokens — looked up by hash on every /auth/refresh call,
        // so a unique index on TokenHash makes that a constant-time check.
        // We also need to list active tokens per user for revoke-all on
        // logout, hence the UserId index. Hash is the SHA-256 hex string
        // (64 chars).
        builder.Entity<RefreshToken>().HasQueryFilter(t => !t.IsDeleted);
        builder.Entity<RefreshToken>().Property(t => t.UserId).HasMaxLength(450).IsRequired();
        builder.Entity<RefreshToken>().Property(t => t.TokenHash).HasMaxLength(64).IsRequired();
        builder.Entity<RefreshToken>().HasIndex(t => t.TokenHash).IsUnique();
        builder.Entity<RefreshToken>().HasIndex(t => t.UserId);
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<TilmezBus.Domain.Common.BaseEntity>())
        {
            if (entry.State == EntityState.Modified)
                entry.Entity.UpdatedAt = DateTime.UtcNow;
        }
        return await base.SaveChangesAsync(cancellationToken);
    }
}
