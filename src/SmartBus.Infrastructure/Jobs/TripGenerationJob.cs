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

        // 2b. Build a (type, driverId, assistantId) → Trip lookup over ALL Scheduled trips
        // (any date). If a schedule being processed matches a crew already on a Scheduled
        // trip we roll that existing trip's ScheduledDeparture forward to today instead of
        // creating a new one.
        var scheduledTrips = await _context.Trips
            .Where(t => !t.IsTemplate && t.Status == TripStatus.Scheduled)
            .ToListAsync();

        var scheduledTripBusIds = scheduledTrips.Select(t => t.BusId).Distinct().ToList();
        var crewByBus = (await _context.BusSchedules
            .Where(s => scheduledTripBusIds.Contains(s.BusId))
            .Select(s => new
            {
                s.BusId,
                s.MorningDriverId,
                s.MorningAssistantId,
                s.ReturnDriverId,
                s.ReturnAssistantId
            })
            .ToListAsync())
            .ToDictionary(x => x.BusId);

        var crewToTrip = new Dictionary<(TripType Type, Guid DriverId, Guid AssistantId), Trip>();
        foreach (var t in scheduledTrips.OrderBy(t => t.ScheduledDeparture))
        {
            if (!crewByBus.TryGetValue(t.BusId, out var crew)) continue;
            Guid? driverId = null, assistantId = null;
            if (t.Type == TripType.Morning) { driverId = crew.MorningDriverId; assistantId = crew.MorningAssistantId; }
            else if (t.Type == TripType.Return) { driverId = crew.ReturnDriverId; assistantId = crew.ReturnAssistantId; }
            if (driverId is null || assistantId is null) continue;
            var key = (t.Type, driverId.Value, assistantId.Value);
            if (!crewToTrip.ContainsKey(key)) crewToTrip[key] = t;
        }

        // 3. Students grouped by bus — via the BusSchedule ↔ Student join
        var studentsByBus = await _context.BusScheduleStudents
            .Where(x => busIds.Contains(x.BusSchedule.BusId))
            .Select(x => new { x.StudentId, x.BusSchedule.BusId })
            .ToListAsync();

        var studentMap = studentsByBus
            .GroupBy(s => s.BusId)
            .ToDictionary(g => g.Key, g => g.Select(s => s.StudentId).ToList());

        // 4. Create (or roll forward) trips for each schedule direction.
        //    If a Scheduled trip already exists for the same (type, driver, assistant),
        //    update its ScheduledDeparture to today instead of creating a duplicate.
        int created = 0;
        int rolledForward = 0;
        var newTrips = new List<(Guid TripId, Guid BusId)>();
        var rolledForwardTrips = new List<(Guid TripId, Guid BusId)>();

        foreach (var sched in schedules)
        {
            // Skip schedules with no assigned students — nothing to run.
            if (sched.StudentCount <= 0) continue;

            var canMorning = sched.MorningDriverId is not null && sched.MorningAssistantId is not null;
            var canReturn  = sched.ReturnDriverId  is not null && sched.ReturnAssistantId  is not null;

            if (canMorning && !alreadyExists.Contains((sched.BusId, TripType.Morning)))
            {
                var key = (TripType.Morning, sched.MorningDriverId!.Value, sched.MorningAssistantId!.Value);
                var departure = today.Add(sched.MorningTime.ToTimeSpan());

                if (crewToTrip.TryGetValue(key, out var existing))
                {
                    _logger.LogInformation(
                        "[TripGen] Rolling forward ذهاب trip {TripId} (bus={BusId}) — same crew (driver={DriverId}, assistant={AssistantId}); ScheduledDeparture set to {Departure}.",
                        existing.Id, existing.BusId, key.Item2, key.Item3, departure);
                    existing.ScheduledDeparture = departure;
                    rolledForwardTrips.Add((existing.Id, existing.BusId));
                    rolledForward++;
                }
                else
                {
                    var trip = new Trip
                    {
                        BusId              = sched.BusId,
                        Type               = TripType.Morning,
                        Name               = $"{sched.Bus.PlateNumber} — ذهاب — {today:dd/MM/yyyy}",
                        ScheduledDeparture = departure,
                        RepeatDays         = 0,
                        Status             = TripStatus.Scheduled,
                        IsTemplate         = false
                    };
                    _context.Trips.Add(trip);
                    newTrips.Add((trip.Id, sched.BusId));
                    crewToTrip[key] = trip;
                    created++;
                }
            }

            if (canReturn && !alreadyExists.Contains((sched.BusId, TripType.Return)))
            {
                var key = (TripType.Return, sched.ReturnDriverId!.Value, sched.ReturnAssistantId!.Value);
                var departure = today.Add(sched.ReturnTime.ToTimeSpan());

                if (crewToTrip.TryGetValue(key, out var existing))
                {
                    _logger.LogInformation(
                        "[TripGen] Rolling forward إياب trip {TripId} (bus={BusId}) — same crew (driver={DriverId}, assistant={AssistantId}); ScheduledDeparture set to {Departure}.",
                        existing.Id, existing.BusId, key.Item2, key.Item3, departure);
                    existing.ScheduledDeparture = departure;
                    rolledForwardTrips.Add((existing.Id, existing.BusId));
                    rolledForward++;
                }
                else
                {
                    var trip = new Trip
                    {
                        BusId              = sched.BusId,
                        Type               = TripType.Return,
                        Name               = $"{sched.Bus.PlateNumber} — إياب — {today:dd/MM/yyyy}",
                        ScheduledDeparture = departure,
                        RepeatDays         = 0,
                        Status             = TripStatus.Scheduled,
                        IsTemplate         = false
                    };
                    _context.Trips.Add(trip);
                    newTrips.Add((trip.Id, sched.BusId));
                    crewToTrip[key] = trip;
                    created++;
                }
            }
        }

        // Flush new + updated trips so their IDs are stable before we reference them in StudentTrips
        if (created > 0 || rolledForward > 0)
            await _context.SaveChangesAsync();

        // 5. Backfill StudentTrip rows for all trips we touched today (new + pre-existing + rolled-forward).
        //    This makes the job idempotent: re-running it after students are re-assigned
        //    or after an earlier failed run will always fill in missing rows.
        var allTripBusMap = existingTrips
            .Select(t => (TripId: t.Id, BusId: t.BusId))
            .Concat(newTrips)
            .Concat(rolledForwardTrips)
            .Distinct()
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
            "[TripGen] Date={Date} NewTrips={Created} RolledForward={Rolled} NewStudentRows={StudentRows}",
            today.ToString("yyyy-MM-dd"), created, rolledForward, studentTripCount);
        return created;
    }

    private static byte DayOfWeekToBit(DayOfWeek dow) => (byte)(1 << (int)dow);
}
