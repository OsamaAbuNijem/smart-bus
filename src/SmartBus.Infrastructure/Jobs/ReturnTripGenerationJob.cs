using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;
using SmartBus.Infrastructure.Persistence;

namespace SmartBus.Infrastructure.Jobs;

/// <summary>
/// Runs daily at a configurable time (default 12:05 AM) and creates the إياب (Return) trip
/// instance for every bus whose BusSchedule RepeatDays bitmask includes today's weekday.
/// Idempotent — safe to run multiple times on the same day.
/// </summary>
public class ReturnTripGenerationJob
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ReturnTripGenerationJob> _logger;

    public ReturnTripGenerationJob(ApplicationDbContext context, ILogger<ReturnTripGenerationJob> logger)
    {
        _context = context;
        _logger  = logger;
    }

    public async Task ExecuteAsync(bool forceToday = false)
    {
        await RunAsync(forceToday);
    }

    /// <returns>Number of new إياب trips created.</returns>
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
            _logger.LogInformation("[ReturnJob] No schedules found (forceToday={Force}, day={Day})", forceToday, today.DayOfWeek);
            return 0;
        }

        // Find buses that already have a return instance for today
        var busIds = schedules.Select(s => s.BusId).ToList();
        var existingBusIds = await _context.Trips
            .Where(t => !t.IsDeleted && !t.IsTemplate
                        && t.Type == TripType.Return
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

            // Skip incomplete schedules — no students or missing return driver/assistant.
            if (sched.StudentCount <= 0 || sched.ReturnDriverId is null || sched.ReturnAssistantId is null)
                continue;

            var departure = today.Add(sched.ReturnTime.ToTimeSpan());
            _context.Trips.Add(new Trip
            {
                BusId              = sched.BusId,
                Type               = TripType.Return,
                Name               = $"{sched.Bus.PlateNumber} — إياب — {today:dd/MM/yyyy}",
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
            _logger.LogInformation("[ReturnJob] Created {Count} إياب trips for {Date}", created, today.ToString("yyyy-MM-dd"));
        }
        else
        {
            _logger.LogInformation("[ReturnJob] All إياب trips for {Date} already exist", today.ToString("yyyy-MM-dd"));
        }

        return created;
    }

    private static byte DayOfWeekToBit(DayOfWeek dow) => (byte)(1 << (int)dow);
}
