using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Queries.GetMyTodayTrips;

public class GetMyTodayTripsQueryHandler
    : IRequestHandler<GetMyTodayTripsQuery, Result<List<MyTodayTripDto>>>
{
    /// <summary>Hard cap on rows returned to the assistant home. The card
    /// list shows the most recent N trips for this fleet, status-sorted so
    /// live + scheduled bubble to the top.</summary>
    private const int MaxTrips = 10;

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

        // Drivers and Assistants both live in the Drivers table; DriverType
        // disambiguates. We just need the school from whichever Drivers row
        // is wired to this UserId.
        var driver = await _context.Drivers
            .FirstOrDefaultAsync(d => d.UserId == userId, ct);
        Guid? schoolId = driver?.SchoolId;

        // Visible buses = every bus in the caller's school. We used to also
        // union in whatever BusSchedule slots referenced the driver, but
        // BusSchedule has been removed; trips are created per-scan and the
        // school filter is enough.
        var busIds = schoolId is null
            ? new List<Guid>()
            : await _context.Buses
                .Where(b => b.SchoolId == schoolId && !b.IsDeleted)
                .Select(b => b.Id)
                .ToListAsync(ct);
        if (busIds.Count == 0)
            return Result<List<MyTodayTripDto>>.Success(new List<MyTodayTripDto>());

        var schedulesByBus = await _context.Buses
            .Where(b => busIds.Contains(b.Id))
            .ToDictionaryAsync(b => b.Id, b => b.PlateNumber, ct);

        // Most recent MaxTrips real trips on those buses. Date window
        // dropped — the home card now surfaces the last 10 trips overall
        // (live → scheduled → completed in the in-memory sort below).
        var tripsRaw = await _context.Trips
            .Where(t => !t.IsTemplate && busIds.Contains(t.BusId))
            .OrderByDescending(t => t.ScheduledDeparture)
            .Take(MaxTrips)
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
