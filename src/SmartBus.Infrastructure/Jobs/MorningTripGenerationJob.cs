using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;
using SmartBus.Infrastructure.Persistence;

namespace SmartBus.Infrastructure.Jobs;

/// <summary>
/// Runs daily at 12:00 AM and creates the ذهاب (Morning) trip instance for every bus
/// whose BusSchedule RepeatDays bitmask includes today's weekday.
/// Idempotent — safe to run multiple times on the same day.
/// </summary>
public class MorningTripGenerationJob
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<MorningTripGenerationJob> _logger;

    public MorningTripGenerationJob(ApplicationDbContext context, ILogger<MorningTripGenerationJob> logger)
    {
        _context = context;
        _logger  = logger;
    }

    /// <param name="forceToday">
    /// When true (manual trigger), bypass the RepeatDays day-of-week check
    /// and create trips for every bus that has a schedule.
    /// </param>
    public async Task ExecuteAsync(bool forceToday = false)
    {
        await RunAsync(forceToday);
    }

    /// <returns>Number of new ذهاب trips created.</returns>
    public async Task<int> RunAsync(bool forceToday = false)
    {
        var today    = DateTime.UtcNow.Date;
        var todayBit = DayOfWeekToBit(today.DayOfWeek);

        var schedulesQuery = _context.BusSchedules
            .Where(s => !s.IsDeleted)
            .Include(s => s.Bus);

        var schedules = forceToday
            ? await schedulesQuery.ToListAsync()
            : await schedulesQuery.Where(s => (s.RepeatDays & todayBit) != 0).ToListAsync();

        if (schedules.Count == 0)
        {
            _logger.LogInformation("[MorningJob] No schedules found (forceToday={Force}, day={Day})", forceToday, today.DayOfWeek);
            return 0;
        }

        // Find buses that already have a morning instance for today
        var busIds = schedules.Select(s => s.BusId).ToList();
        var existingBusIds = await _context.Trips
            .Where(t => !t.IsDeleted && !t.IsTemplate
                        && t.Type == TripType.Morning
                        && t.ScheduledDeparture >= today
                        && t.ScheduledDeparture < today.AddDays(1)
                        && busIds.Contains(t.BusId))
            .Select(t => t.BusId)
            .ToListAsync();

        var existingSet = existingBusIds.ToHashSet();

        int created = 0;
        foreach (var sched in schedules)
        {
            if (existingSet.Contains(sched.BusId)) continue;

            var departure = today.Add(sched.MorningTime.ToTimeSpan());
            _context.Trips.Add(new Trip
            {
                BusId              = sched.BusId,
                Type               = TripType.Morning,
                Name               = $"{sched.Bus.PlateNumber} — ذهاب — {today:dd/MM/yyyy}",
                ScheduledDeparture = departure,
                RepeatDays         = 0,
                Status             = TripStatus.Scheduled,
                IsTemplate         = false
            });
            created++;
        }

        if (created > 0)
        {
            await _context.SaveChangesAsync();
            _logger.LogInformation("[MorningJob] Created {Count} ذهاب trips for {Date}", created, today.ToString("yyyy-MM-dd"));
        }
        else
        {
            _logger.LogInformation("[MorningJob] All ذهاب trips for {Date} already exist", today.ToString("yyyy-MM-dd"));
        }

        return created;
    }

    private static byte DayOfWeekToBit(DayOfWeek dow) => (byte)(1 << (int)dow);
}
