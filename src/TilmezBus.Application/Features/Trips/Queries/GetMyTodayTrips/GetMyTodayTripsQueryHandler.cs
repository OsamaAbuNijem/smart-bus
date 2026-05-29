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
        // disambiguates. We use the row's Id to match Trip.DriverId /
        // Trip.AssistantId, and the school to optionally widen the view.
        var driver = await _context.Drivers
            .FirstOrDefaultAsync(d => d.UserId == userId, ct);
        if (driver is null)
            return Result<List<MyTodayTripDto>>.Success(new List<MyTodayTripDto>());

        var driverRowId = driver.Id;
        var isAssistant = driver.DriverType == DriverType.Assistant;

        // Most recent MaxTrips trips assigned to THIS user (matched by the
        // Drivers.Id pointed at by Trip.AssistantId or Trip.DriverId). The
        // old filter looked at every bus in the school, which left an
        // assistant with trips outside their school's bus pool seeing an
        // empty home — and let them see other assistants' trips.
        var assignedQuery = _context.Trips
            .Where(t => !t.IsTemplate
                     && (isAssistant
                         ? t.AssistantId == driverRowId
                         : t.DriverId    == driverRowId));

        var tripsRaw = await assignedQuery
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

        // Resolve bus plate numbers for whatever buses we ended up with.
        var busIds = tripsRaw.Select(t => t.BusId).Distinct().ToList();
        var schedulesByBus = busIds.Count == 0
            ? new Dictionary<Guid, string>()
            : await _context.Buses
                .Where(b => busIds.Contains(b.Id))
                .ToDictionaryAsync(b => b.Id, b => b.PlateNumber, ct);

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
