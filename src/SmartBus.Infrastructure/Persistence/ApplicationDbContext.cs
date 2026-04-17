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
    public DbSet<Alert> Alerts => Set<Alert>();
    public DbSet<EmergencyContact> EmergencyContacts => Set<EmergencyContact>();
    public DbSet<StudentAllergy> StudentAllergies => Set<StudentAllergy>();
    public DbSet<School> Schools => Set<School>();

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
        builder.Entity<Alert>().HasQueryFilter(a => !a.IsDeleted);
        builder.Entity<EmergencyContact>().HasQueryFilter(e => !e.IsDeleted);
        builder.Entity<StudentAllergy>().HasQueryFilter(a => !a.IsDeleted);
        builder.Entity<School>().HasQueryFilter(s => !s.IsDeleted);

        // Bus → Assistant: Bus owns the FK (AssistantId)
        builder.Entity<Bus>()
            .HasOne(b => b.Assistant)
            .WithOne(a => a.Bus)
            .HasForeignKey<Bus>(b => b.AssistantId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.SetNull);

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
