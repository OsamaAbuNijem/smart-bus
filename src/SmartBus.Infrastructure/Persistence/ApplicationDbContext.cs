using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;
using SmartBus.Infrastructure.Identity;

namespace SmartBus.Infrastructure.Persistence;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser>, IApplicationDbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<Bus> Buses => Set<Bus>();
    public DbSet<Driver> Drivers => Set<Driver>();
    public DbSet<Assistant> Assistants => Set<Assistant>();
    public DbSet<Route> Routes => Set<Route>();
    public DbSet<Stop> Stops => Set<Stop>();
    public DbSet<Student> Students => Set<Student>();
    public DbSet<Parent> Parents => Set<Parent>();
    public DbSet<Trip> Trips => Set<Trip>();
    public DbSet<StudentTrip> StudentTrips => Set<StudentTrip>();
    public DbSet<Attendance> Attendances => Set<Attendance>();
    public DbSet<AbsenceRequest> AbsenceRequests => Set<AbsenceRequest>();
    public DbSet<BusLocation> BusLocations => Set<BusLocation>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<NotificationTemplate> NotificationTemplates =>
        Set<NotificationTemplate>();
    public DbSet<Alert> Alerts => Set<Alert>();
    public DbSet<EmergencyContact> EmergencyContacts => Set<EmergencyContact>();
    public DbSet<StudentAllergy> StudentAllergies => Set<StudentAllergy>();
    public DbSet<School> Schools => Set<School>();
    public DbSet<Subscription> Subscriptions => Set<Subscription>();
    public DbSet<SubscriptionStudent> SubscriptionStudents => Set<SubscriptionStudent>();
    public DbSet<BusSchedule> BusSchedules => Set<BusSchedule>();
    public DbSet<BusScheduleStudent> BusScheduleStudents => Set<BusScheduleStudent>();
    public DbSet<EmployeeQrToken> EmployeeQrTokens => Set<EmployeeQrToken>();
    public DbSet<StudentQrToken>  StudentQrTokens  => Set<StudentQrToken>();
    public DbSet<UserDeviceToken> UserDeviceTokens => Set<UserDeviceToken>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        builder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        // Soft-delete filters
        builder.Entity<Bus>().HasQueryFilter(b => !b.IsDeleted);
        builder.Entity<BusLocation>().HasQueryFilter(l => !l.IsDeleted);
        builder.Entity<Driver>().HasQueryFilter(d => !d.IsDeleted);
        builder.Entity<Assistant>().HasQueryFilter(a => !a.IsDeleted);
        builder.Entity<Route>().HasQueryFilter(r => !r.IsDeleted);
        builder.Entity<Stop>().HasQueryFilter(s => !s.IsDeleted);
        builder.Entity<Student>().HasQueryFilter(s => !s.IsDeleted);
        builder.Entity<Parent>().HasQueryFilter(p => !p.IsDeleted);
        builder.Entity<Trip>().HasQueryFilter(t => !t.IsDeleted);
        builder.Entity<StudentTrip>().HasQueryFilter(st => !st.IsDeleted);
        builder.Entity<Attendance>().HasQueryFilter(a => !a.IsDeleted);
        builder.Entity<AbsenceRequest>().HasQueryFilter(a => !a.IsDeleted);
        builder.Entity<Notification>().HasQueryFilter(n => !n.IsDeleted);
        builder.Entity<NotificationTemplate>().HasQueryFilter(t => !t.IsDeleted);
        // One template per (Type, LanguageCode) — soft-deleted rows allowed
        // so we can keep history when an admin re-edits copy.
        builder.Entity<NotificationTemplate>()
            .HasIndex(t => new { t.Type, t.LanguageCode })
            .IsUnique()
            .HasFilter("\"IsDeleted\" = false");
        builder.Entity<Alert>().HasQueryFilter(a => !a.IsDeleted);
        builder.Entity<EmergencyContact>().HasQueryFilter(e => !e.IsDeleted);
        builder.Entity<StudentAllergy>().HasQueryFilter(a => !a.IsDeleted);
        builder.Entity<School>().HasQueryFilter(s => !s.IsDeleted);
        builder.Entity<BusSchedule>().HasQueryFilter(s => !s.IsDeleted);
        builder.Entity<EmployeeQrToken>().HasQueryFilter(t => !t.IsDeleted);

        // ── Subscriptions ──────────────────────────────────────────────────
        builder.Entity<Subscription>().HasQueryFilter(s => !s.IsDeleted);

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

        // Token uniqueness — soft-deleted rows excluded so reissues don't collide.
        builder.Entity<EmployeeQrToken>()
            .HasIndex(t => t.Token)
            .IsUnique()
            .HasFilter("\"IsDeleted\" = false");

        builder.Entity<EmployeeQrToken>()
            .HasIndex(t => new { t.SchoolId, t.Type, t.IsUsed });

        builder.Entity<EmployeeQrToken>()
            .HasOne(t => t.School)
            .WithMany()
            .HasForeignKey(t => t.SchoolId)
            .OnDelete(DeleteBehavior.Cascade);

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

        // One schedule per bus
        builder.Entity<BusSchedule>()
            .HasIndex(s => s.BusId)
            .IsUnique();

        // BusSchedule → Driver FKs (four optional relationships; NoAction to avoid cascade cycles)
        builder.Entity<BusSchedule>()
            .HasOne(s => s.MorningDriver)
            .WithMany()
            .HasForeignKey(s => s.MorningDriverId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.NoAction);

        builder.Entity<BusSchedule>()
            .HasOne(s => s.MorningAssistant)
            .WithMany()
            .HasForeignKey(s => s.MorningAssistantId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.NoAction);

        builder.Entity<BusSchedule>()
            .HasOne(s => s.ReturnDriver)
            .WithMany()
            .HasForeignKey(s => s.ReturnDriverId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.NoAction);

        builder.Entity<BusSchedule>()
            .HasOne(s => s.ReturnAssistant)
            .WithMany()
            .HasForeignKey(s => s.ReturnAssistantId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.NoAction);

        // BusSchedule ↔ Student join
        builder.Entity<BusScheduleStudent>()
            .HasKey(x => new { x.BusScheduleId, x.StudentId });

        builder.Entity<BusScheduleStudent>()
            .HasQueryFilter(x => !x.BusSchedule.IsDeleted && !x.Student.IsDeleted);

        builder.Entity<BusScheduleStudent>()
            .HasOne(x => x.BusSchedule)
            .WithMany(s => s.Students)
            .HasForeignKey(x => x.BusScheduleId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<BusScheduleStudent>()
            .HasOne(x => x.Student)
            .WithMany()
            .HasForeignKey(x => x.StudentId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<BusScheduleStudent>()
            .HasIndex(x => x.StudentId);

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

        // StudentTrip composite index
        builder.Entity<StudentTrip>()
            .HasIndex(st => new { st.StudentId, st.TripId })
            .IsUnique();

        // Attendance composite index
        builder.Entity<Attendance>()
            .HasIndex(a => new { a.StudentId, a.TripId, a.Date })
            .IsUnique();

        // ── Hot-path indexes (based on query handler scan) ────────────────
        // List queries sort by CreatedAt DESC with IsDeleted=false predicate:
        builder.Entity<Bus>()    .HasIndex(b => new { b.IsDeleted, b.CreatedAt });
        builder.Entity<Driver>() .HasIndex(d => new { d.IsDeleted, d.CreatedAt });
        builder.Entity<Student>().HasIndex(s => new { s.IsDeleted, s.CreatedAt });
        builder.Entity<Trip>()   .HasIndex(t => new { t.IsDeleted, t.ScheduledDeparture });
        builder.Entity<Alert>()  .HasIndex(a => new { a.IsDeleted, a.CreatedAt });

        // Alerts page filters by Status (pending vs resolved):
        builder.Entity<Alert>().HasIndex(a => new { a.Status, a.CreatedAt });

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
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<SmartBus.Domain.Common.BaseEntity>())
        {
            if (entry.State == EntityState.Modified)
                entry.Entity.UpdatedAt = DateTime.UtcNow;
        }
        return await base.SaveChangesAsync(cancellationToken);
    }
}
