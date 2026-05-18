using MediatR;

namespace SmartBus.Application.Features.Dashboard.Queries.GetLiveDashboardStats;

/// <summary>
/// Real-time view of what's currently on the road for one school: how many
/// trips are in progress (split by type), how many students are currently
/// boarded, and a per-trip rundown with a projected end time the client
/// can count down against.
/// </summary>
public record GetLiveDashboardStatsQuery(Guid SchoolId) : IRequest<LiveDashboardStatsDto>;

public record LiveDashboardStatsDto(
    LiveBreakdownDto Overall,
    LiveBreakdownDto Morning,
    LiveBreakdownDto Return,
    DateTime ServerNowUtc,
    IReadOnlyList<LiveTripDto> Trips);

/// <summary>
/// Trips = in-progress trip count.
/// Students = students currently on board (StudentTrip.BoardingStatus = Boarded).
/// </summary>
public record LiveBreakdownDto(int Trips, int Students);

public record LiveTripDto(
    Guid Id,
    string BusPlateNumber,
    string TripType,            // "Morning" | "Return"
    DateTime ActualDepartureUtc,
    DateTime ExpectedEndUtc,    // ActualDeparture + configured duration for the type
    int Boarded,                // currently on the bus
    int Roster,                 // total scheduled (incl. waiting/absent/dropped)
    string? DriverName,
    string? AssistantName);
