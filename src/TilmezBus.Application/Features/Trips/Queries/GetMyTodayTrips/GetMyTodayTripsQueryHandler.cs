using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Queries.GetMyTodayTrips;

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

        // Caller is either in the Drivers table (Driver/Assistant role) or
        // the parallel Assistants table (QR-registered path). Resolve their
        // school from whichever matches so we can still show school-wide
        // trips when they aren't in any BusSchedule slot.
        var driver = await _context.Drivers
            .FirstOrDefaultAsync(d => d.UserId == userId, ct);
        Guid? schoolId = driver?.SchoolId;
        if (schoolId is null)
        {
            schoolId = await _context.Assistants
                .Where(a => a.UserId == userId && !a.IsDeleted)
                .Select(a => a.SchoolId)
                .FirstOrDefaultAsync(ct);
        }

        var scheduleBusIds = driver is null
            ? new List<Guid>()
            : await _context.BusSchedules
                .Where(s =>
                    s.MorningDriverId    == driver.Id ||
                    s.MorningAssistantId == driver.Id ||
                    s.ReturnDriverId     == driver.Id ||
                    s.ReturnAssistantId  == driver.Id)
                .Select(s => s.BusId)
                .Distinct()
                .ToListAsync(ct);

        var today     = DateTime.UtcNow.Date;
        var tomorrow  = today.AddDays(1);
        var rangeFrom = today.AddDays(-LookbackDays);

        // Visible buses = whatever the schedule says ∪ every bus in the
        // caller's school. The school union ensures assistants who manually
        // create trips (no schedule slot) still see them in today's list.
        var schoolBusIds = schoolId is null
            ? new List<Guid>()
            : await _context.Buses
                .Where(b => b.SchoolId == schoolId && !b.IsDeleted)
                .Select(b => b.Id)
                .ToListAsync(ct);
        var busIds = scheduleBusIds.Concat(schoolBusIds).Distinct().ToList();
        if (busIds.Count == 0)
            return Result<List<MyTodayTripDto>>.Success(new List<MyTodayTripDto>());

        var schedulesByBus = await _context.Buses
            .Where(b => busIds.Contains(b.Id))
            .ToDictionaryAsync(b => b.Id, b => b.PlateNumber, ct);

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

        // Trip → plate. Live (InProgress) sorts first, then Scheduled, then
        // anything else (Completed). Newest within each bucket.
        var result = tripsRaw
            .Select(t =>
            {
                var plate = schedulesByBus.GetValueOrDefault(t.BusId, string.Empty);
                return new MyTodayTripDto(
                    t.Id, t.BusId, plate,
                    t.Type.ToString(),
                    t.Status.ToString(),
                    t.ScheduledDeparture,
                    t.ActualDeparture,
                    t.ActualArrival,
                    t.StudentCount,
                    t.BoardedCount);
            })
            .OrderBy(r => r.Status == "InProgress" ? 0
                          : r.Status == "Scheduled" ? 1 : 2)
            .ThenByDescending(r => r.ScheduledDeparture)
            .ToList();

        return Result<List<MyTodayTripDto>>.Success(result);
    }

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
