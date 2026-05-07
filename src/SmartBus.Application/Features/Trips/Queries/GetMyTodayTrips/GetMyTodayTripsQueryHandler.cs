using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Queries.GetMyTodayTrips;

public class GetMyTodayTripsQueryHandler
    : IRequestHandler<GetMyTodayTripsQuery, Result<List<MyTodayTripDto>>>
{
    /// <summary>How many calendar days of past completed trips to surface
    /// on the assistant home alongside today's live + scheduled rows.</summary>
    private const int LookbackDays = 2;

    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetMyTodayTripsQueryHandler(
        IApplicationDbContext context,
        ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<Result<List<MyTodayTripDto>>> Handle(
        GetMyTodayTripsQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        if (string.IsNullOrEmpty(userId))
            return Result<List<MyTodayTripDto>>.Failure("Unauthenticated.");

        var driver = await _context.Drivers
            .FirstOrDefaultAsync(d => d.UserId == userId, ct);
        if (driver is null)
            return Result<List<MyTodayTripDto>>.Success(new List<MyTodayTripDto>());

        var schedules = await _context.BusSchedules
            .Where(s =>
                s.MorningDriverId    == driver.Id ||
                s.MorningAssistantId == driver.Id ||
                s.ReturnDriverId     == driver.Id ||
                s.ReturnAssistantId  == driver.Id)
            .Select(s => new
            {
                s.Id,
                s.BusId,
                BusPlate = s.Bus!.PlateNumber,
                s.MorningTime,
                s.ReturnTime,
                s.MorningDriverId,
                s.MorningAssistantId,
                s.ReturnDriverId,
                s.ReturnAssistantId
            })
            .ToListAsync(ct);

        if (schedules.Count == 0)
            return Result<List<MyTodayTripDto>>.Success(new List<MyTodayTripDto>());

        var today     = DateTime.UtcNow.Date;
        var tomorrow  = today.AddDays(1);
        var rangeFrom = today.AddDays(-LookbackDays);
        var busIds    = schedules.Select(s => s.BusId).Distinct().ToList();

        // Real trips on those buses across the window.
        var tripsRaw = await _context.Trips
            .Where(t => !t.IsTemplate
                        && busIds.Contains(t.BusId)
                        && t.ScheduledDeparture >= rangeFrom
                        && t.ScheduledDeparture <  tomorrow)
            .Select(t => new TripFacts(
                t.Id,
                t.BusId,
                t.Type,
                t.Status,
                t.ScheduledDeparture,
                t.ActualDeparture,
                t.ActualArrival,
                t.StudentTrips.Count(),
                t.StudentTrips.Count(st => st.BoardingStatus == BoardingStatus.Boarded)))
            .ToListAsync(ct);

        var result = new List<MyTodayTripDto>();
        var schedulesByBus = schedules.ToDictionary(s => s.BusId);

        // Surface every real trip in the window — assistant sees live ones
        // alongside completed history.
        foreach (var t in tripsRaw)
        {
            var sched = schedulesByBus.GetValueOrDefault(t.BusId);
            var plate = sched?.BusPlate ?? string.Empty;
            result.Add(new MyTodayTripDto(
                t.Id, t.BusId, plate,
                t.Type.ToString(),
                t.Status.ToString(),
                t.ScheduledDeparture,
                t.ActualDeparture,
                t.ActualArrival,
                t.StudentCount,
                t.BoardedCount));
        }

        // For TODAY only, synthesize "Scheduled" placeholder rows for legs
        // that don't yet have a Trip row — so the assistant always sees
        // their next leg even before the bus departs.
        // Multiple trips can share (bus, type) within the same day (e.g. an
        // earlier completed Return + a fresh one); we just need to know
        // *whether any* exists, so collect into a HashSet rather than a Dict.
        var todayLegsCovered = tripsRaw
            .Where(t => t.ScheduledDeparture >= today)
            .Select(t => (t.BusId, t.Type))
            .ToHashSet();

        foreach (var sched in schedules)
        {
            var inMorning = sched.MorningDriverId == driver.Id || sched.MorningAssistantId == driver.Id;
            var inReturn  = sched.ReturnDriverId  == driver.Id || sched.ReturnAssistantId  == driver.Id;

            if (inMorning && !todayLegsCovered.Contains((sched.BusId, TripType.Morning)))
            {
                result.Add(Placeholder(sched.BusId, sched.BusPlate, TripType.Morning,
                    today.Add(sched.MorningTime.ToTimeSpan())));
            }
            if (inReturn && !todayLegsCovered.Contains((sched.BusId, TripType.Return)))
            {
                result.Add(Placeholder(sched.BusId, sched.BusPlate, TripType.Return,
                    today.Add(sched.ReturnTime.ToTimeSpan())));
            }
        }

        // Live first, then scheduled (today), then completed/recent — newest first.
        return Result<List<MyTodayTripDto>>.Success(result
            .OrderBy(r => r.Status == "InProgress" ? 0 : r.Status == "Scheduled" ? 1 : 2)
            .ThenByDescending(r => r.ScheduledDeparture)
            .ToList());
    }

    private static MyTodayTripDto Placeholder(
        Guid busId, string plate, TripType type, DateTime scheduled) =>
        new(null, busId, plate, type.ToString(), "Scheduled",
            scheduled, null, null, 0, 0);

    private record TripFacts(
        Guid Id,
        Guid BusId,
        TripType Type,
        TripStatus Status,
        DateTime ScheduledDeparture,
        DateTime? ActualDeparture,
        DateTime? ActualArrival,
        int StudentCount,
        int BoardedCount);
}
