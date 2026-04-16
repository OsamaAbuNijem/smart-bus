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
    public DbSet<Route> Routes => Set<Route>();
    public DbSet<Stop> Stops => Set<Stop>();
    public DbSet<Student> Students => Set<Student>();
    public DbSet<Trip> Trips => Set<Trip>();
    public DbSet<BusLocation> BusLocations => Set<BusLocation>();
    public DbSet<Notification> Notifications => Set<Notification>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        builder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        builder.Entity<Bus>().HasQueryFilter(b => !b.IsDeleted);
        builder.Entity<Driver>().HasQueryFilter(d => !d.IsDeleted);
        builder.Entity<Route>().HasQueryFilter(r => !r.IsDeleted);
        builder.Entity<Student>().HasQueryFilter(s => !s.IsDeleted);
        builder.Entity<Trip>().HasQueryFilter(t => !t.IsDeleted);
        builder.Entity<Notification>().HasQueryFilter(n => !n.IsDeleted);
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
