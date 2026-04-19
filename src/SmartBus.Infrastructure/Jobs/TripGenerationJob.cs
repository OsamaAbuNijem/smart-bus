using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;
using SmartBus.Infrastructure.Persistence;

namespace SmartBus.Infrastructure.Jobs;

/// <summary>
/// Runs daily at 12:05 AM. For every bus with a matching BusSchedule creates:
///   • one ذهاب Trip instance
///   • one إياب Trip instance
///   • one StudentTrip row (Waiting) for every student assigned to that bus
/// Idempotent — safe to run multiple times on the same day.
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

    public async Task ExecuteAsync(bool forceToday = false) => await RunAsync(forceToday);

    /// <returns>Total number of new trips created.</returns>
    public async Task<int> RunAsync(bool forceToday = false)
    {
        var today    = DateTime.UtcNow.Date;
        var todayBit = DayOfWeekToBit(today.DayOfWeek);

        // 1. Load matching schedules
        var schedules = forceToday
            ? await _context.BusSchedules.Include(s => s.Bus).ToListAsync()
            : await _context.BusSchedules.Where(s => (s.RepeatDays & todayBit) != 0).Include(s => s.Bus).ToListAsync();

        if (schedules.Count == 0)
        {
            _logger.LogInformation("[TripGen] No schedules (forceToday={Force}, day={Day})", forceToday, today.DayOfWeek);
            return 0;
        }

        var busIds = schedules.Select(s => s.BusId).Distinct().ToList();

        // 2. Which (busId, type) combos already have a trip today?
        var existingTrips = await _context.Trips
            .Where(t => !t.IsTemplate
                        && t.ScheduledDeparture >= today
                        && t.ScheduledDeparture < today.AddDays(1)
                        && busIds.Contains(t.BusId))
            .Select(t => new { t.Id, t.BusId, t.Type })
            .ToListAsync();

        var alreadyExists = existingTrips.Select(t => (t.BusId, t.Type)).ToHashSet();

        // 3. Students grouped by bus — global query filter handles IsDeleted
        var studentsByBus = await _context.Students
            .Where(s => s.BusId.HasValue && busIds.Contains(s.BusId.Value))
            .Select(s => new { s.Id, BusId = s.BusId!.Value })
            .ToListAsync();

        var studentMap = studentsByBus
            .GroupBy(s => s.BusId)
            .ToDictionary(g => g.Key, g => g.Select(s => s.Id).ToList());

        // 4. Create new trips for any (bus, type) combos not yet generated today
        int created = 0;
        var newTrips = new List<(Guid TripId, Guid BusId)>();

        foreach (var sched in schedules)
        {
            if (!alreadyExists.Contains((sched.BusId, TripType.Morning)))
            {
                var trip = new Trip
                {
                    BusId              = sched.BusId,
                    Type               = TripType.Morning,
                    Name               = $"{sched.Bus.PlateNumber} — ذهاب — {today:dd/MM/yyyy}",
                    ScheduledDeparture = today.Add(sched.MorningTime.ToTimeSpan()),
                    RepeatDays         = 0,
                    Status             = TripStatus.Scheduled,
                    IsTemplate         = false
                };
                _context.Trips.Add(trip);
                newTrips.Add((trip.Id, sched.BusId));
                created++;
            }

            if (!alreadyExists.Contains((sched.BusId, TripType.Return)))
            {
                var trip = new Trip
                {
                    BusId              = sched.BusId,
                    Type               = TripType.Return,
                    Name               = $"{sched.Bus.PlateNumber} — إياب — {today:dd/MM/yyyy}",
                    ScheduledDeparture = today.Add(sched.ReturnTime.ToTimeSpan()),
                    RepeatDays         = 0,
                    Status             = TripStatus.Scheduled,
                    IsTemplate         = false
                };
                _context.Trips.Add(trip);
                newTrips.Add((trip.Id, sched.BusId));
                created++;
            }
        }

        // Flush new trips so their IDs are committed before we reference them in StudentTrips
        if (created > 0)
            await _context.SaveChangesAsync();

        // 5. Backfill StudentTrip rows for ALL of today's trips (new + pre-existing).
        //    This makes the job idempotent: re-running it after students are re-assigned
        //    or after an earlier failed run will always fill in missing rows.
        var allTripBusMap = existingTrips
            .Select(t => (TripId: t.Id, BusId: t.BusId))
            .Concat(newTrips)
            .ToList();

        if (allTripBusMap.Count == 0)
        {
            _logger.LogInformation("[TripGen] No trips to process for {Date}", today.ToString("yyyy-MM-dd"));
            return 0;
        }

        var allTripIds = allTripBusMap.Select(x => x.TripId).ToHashSet();
        var existingStudentTripKeys = (await _context.StudentTrips
            .Where(st => allTripIds.Contains(st.TripId))
            .Select(st => new { st.TripId, st.StudentId })
            .ToListAsync())
            .Select(x => (x.TripId, x.StudentId)).ToHashSet();

        int studentTripCount = 0;
        foreach (var (tripId, busId) in allTripBusMap)
        {
            if (!studentMap.TryGetValue(busId, out var studentIds)) continue;
            foreach (var studentId in studentIds)
            {
                if (existingStudentTripKeys.Contains((tripId, studentId))) continue;
                _context.StudentTrips.Add(new StudentTrip
                {
                    TripId         = tripId,
                    StudentId      = studentId,
                    BoardingStatus = BoardingStatus.Waiting
                });
                studentTripCount++;
            }
        }

        if (studentTripCount > 0)
            await _context.SaveChangesAsync();

        _logger.LogInformation(
            "[TripGen] Date={Date} NewTrips={Created} NewStudentRows={StudentRows}",
            today.ToString("yyyy-MM-dd"), created, studentTripCount);
        return created;
    }

    private static byte DayOfWeekToBit(DayOfWeek dow) => (byte)(1 << (int)dow);
}
