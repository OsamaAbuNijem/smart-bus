using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Options;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Dashboard.Queries.GetLiveDashboardStats;

public class GetLiveDashboardStatsQueryHandler
    : IRequestHandler<GetLiveDashboardStatsQuery, LiveDashboardStatsDto>
{
    private readonly IApplicationDbContext _context;
    private readonly TripDurationOptions  _durations;

    public GetLiveDashboardStatsQueryHandler(
        IApplicationDbContext context,
        IOptions<TripDurationOptions> durations)
    {
        _context   = context;
        _durations = durations.Value;
    }

    public async Task<LiveDashboardStatsDto> Handle(GetLiveDashboardStatsQuery request, CancellationToken cancellationToken)
    {
        var schoolId = request.SchoolId;
        var now      = DateTime.UtcNow;

        // In-progress trips for this school. We pull the minimal shape needed
        // for both the aggregate counts and the per-trip list, then fan out
        // the boarded/roster counts in a single grouped query below.
        var liveTrips = await (
            from t in _context.Trips
            where !t.IsDeleted
               && !t.IsTemplate
               && t.Bus != null && t.Bus.SchoolId == schoolId
               && t.Status == TripStatus.InProgress
               && t.ActualDeparture != null
            from driver    in _context.Drivers.Where(d => d.Id == t.DriverId).DefaultIfEmpty()
            from assistant in _context.Drivers.Where(d => d.Id == t.AssistantId).DefaultIfEmpty()
            select new
            {
                t.Id,
                t.Type,
                t.ActualDeparture,
                BusPlate      = t.Bus!.PlateNumber,
                DriverName    = driver    != null ? driver.FullName    : null,
                AssistantName = assistant != null ? assistant.FullName : null,
            }).ToListAsync(cancellationToken);

        // Single StudentTrip aggregate keyed by trip + boarded-flag. Lets us
        // hand the trip list its per-trip counts without an N+1.
        var tripIds = liveTrips.Select(t => t.Id).ToList();
        var rosterByTrip = tripIds.Count == 0
            ? new Dictionary<Guid, (int Roster, int Boarded)>()
            : await _context.StudentTrips
                .Where(st => !st.IsDeleted && tripIds.Contains(st.TripId))
                .GroupBy(st => st.TripId)
                .Select(g => new
                {
                    TripId  = g.Key,
                    Roster  = g.Count(),
                    Boarded = g.Count(st => st.BoardingStatus == BoardingStatus.Boarded)
                })
                .ToDictionaryAsync(x => x.TripId, x => (x.Roster, x.Boarded), cancellationToken);

        var trips = liveTrips
            .OrderBy(t => t.ActualDeparture)
            .Select(t =>
            {
                var counts = rosterByTrip.TryGetValue(t.Id, out var c) ? c : (Roster: 0, Boarded: 0);
                var duration = t.Type == TripType.Morning
                    ? TimeSpan.FromMinutes(_durations.MorningMinutes)
                    : TimeSpan.FromMinutes(_durations.ReturnMinutes);
                var expectedEnd = (t.ActualDeparture!.Value).Add(duration);
                return new LiveTripDto(
                    Id:                 t.Id,
                    BusPlateNumber:     t.BusPlate,
                    TripType:           t.Type.ToString(),
                    ActualDepartureUtc: t.ActualDeparture!.Value,
                    ExpectedEndUtc:     expectedEnd,
                    Boarded:            counts.Boarded,
                    Roster:             counts.Roster,
                    DriverName:         t.DriverName,
                    AssistantName:      t.AssistantName);
            })
            .ToList();

        int OverallTrips = trips.Count;
        int MorningTrips = trips.Count(t => t.TripType == nameof(TripType.Morning));
        int ReturnTrips  = trips.Count(t => t.TripType == nameof(TripType.Return));

        int OverallBoarded = trips.Sum(t => t.Boarded);
        int MorningBoarded = trips.Where(t => t.TripType == nameof(TripType.Morning)).Sum(t => t.Boarded);
        int ReturnBoarded  = trips.Where(t => t.TripType == nameof(TripType.Return)).Sum(t => t.Boarded);

        return new LiveDashboardStatsDto(
            Overall:      new LiveBreakdownDto(OverallTrips, OverallBoarded),
            Morning:      new LiveBreakdownDto(MorningTrips, MorningBoarded),
            Return:       new LiveBreakdownDto(ReturnTrips,  ReturnBoarded),
            ServerNowUtc: now,
            Trips:        trips);
    }
}
