using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TilmezBus.Infrastructure.Persistence;

namespace TilmezBus.Infrastructure.Jobs;

public class BusTrackingCleanupJob
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<BusTrackingCleanupJob> _logger;

    public BusTrackingCleanupJob(ApplicationDbContext context, ILogger<BusTrackingCleanupJob> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task CleanOldLocationsAsync()
    {
        var cutoff = DateTime.UtcNow.AddDays(-7);
        var deleted = await _context.BusLocations
            .Where(l => l.Timestamp < cutoff)
            .ExecuteDeleteAsync();

        _logger.LogInformation("Cleaned {Count} old bus location records older than {Cutoff}", deleted, cutoff);
    }

    public async Task UpdateInactiveBusStatusAsync()
    {
        var thirtyMinutesAgo = DateTime.UtcNow.AddMinutes(-30);
        var staleBuses = await _context.Buses
            .Where(b => b.LastLocation != null && b.LastLocation.Timestamp < thirtyMinutesAgo)
            .ToListAsync();

        foreach (var bus in staleBuses)
        {
            bus.Status = Domain.Enums.BusStatus.Inactive;
            bus.UpdatedAt = DateTime.UtcNow;
        }

        if (staleBuses.Count > 0)
        {
            await _context.SaveChangesAsync();
            _logger.LogInformation("Marked {Count} buses as inactive due to stale location data", staleBuses.Count);
        }
    }
}
