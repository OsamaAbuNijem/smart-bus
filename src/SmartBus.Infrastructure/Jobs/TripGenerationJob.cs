using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;
using SmartBus.Infrastructure.Persistence;

namespace SmartBus.Infrastructure.Jobs;

/// <summary>
/// Hangfire job that runs daily and generates concrete trip instances (ذهاب + إياب)
/// for every bus whose schedule template matches today's day of the week.
/// The job is idempotent — re-running it on the same day is safe.
/// </summary>
public class TripGenerationJob
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<TripGenerationJob> _logger;

    public TripGenerationJob(ApplicationDbContext context, ILogger<TripGenerationJob> logger)
    {
        _context = context;
        _logger  = logger;
    }

    public async Task GenerateTripsForTodayAsync()
    {
        var today    = DateTime.UtcNow.Date;
        var todayBit = DayOfWeekToBit(today.DayOfWeek);

        // Load all active schedule templates whose repeat mask includes today
        var templates = await _context.Trips
            .Where(t => !t.IsDeleted && t.IsTemplate && (t.RepeatDays & todayBit) != 0)
            .Include(t => t.Bus)
            .ToListAsync();

        if (templates.Count == 0)
        {
            _logger.LogInformation("[TripGen] No schedule templates match today ({Day})", today.DayOfWeek);
            return;
        }

        // Load already-generated instances for today (to avoid duplicates)
        var existingInstanceKeys = await _context.Trips
            .Where(t => !t.IsDeleted && !t.IsTemplate &&
                        t.ScheduledDeparture >= today &&
                        t.ScheduledDeparture < today.AddDays(1))
            .Select(t => new { t.BusId, t.Type })
            .ToListAsync();

        var existingSet = existingInstanceKeys
            .Select(x => (x.BusId, x.Type))
            .ToHashSet();

        var created = 0;
        foreach (var tpl in templates)
        {
            if (existingSet.Contains((tpl.BusId, tpl.Type)))
                continue; // already generated today

            // Combine today's date with the template's time
            var time       = TimeOnly.FromDateTime(tpl.ScheduledDeparture);
            var departure  = today.Add(time.ToTimeSpan());
            var typeLabel  = tpl.Type == TripType.Morning ? "ذهاب" : "إياب";
            var dateLabel  = today.ToString("dd/MM/yyyy");

            var instance = new Trip
            {
                BusId              = tpl.BusId,
                Type               = tpl.Type,
                Name               = $"{tpl.Bus.PlateNumber} — {typeLabel} — {dateLabel}",
                ScheduledDeparture = departure,
                RepeatDays         = 0,          // instances don't repeat
                Status             = TripStatus.Scheduled,
                IsTemplate         = false,
                Notes              = null
            };

            _context.Trips.Add(instance);
            created++;
        }

        if (created > 0)
        {
            await _context.SaveChangesAsync();
            _logger.LogInformation("[TripGen] Created {Count} trip instances for {Date}", created, today.ToString("yyyy-MM-dd"));
        }
        else
        {
            _logger.LogInformation("[TripGen] All trips for {Date} already exist", today.ToString("yyyy-MM-dd"));
        }
    }

    /// <summary>Maps DayOfWeek to the bitmask used in RepeatDays (Sun=1, Mon=2, Tue=4 … Sat=64).</summary>
    private static byte DayOfWeekToBit(DayOfWeek dow) => (byte)(1 << (int)dow);
}
