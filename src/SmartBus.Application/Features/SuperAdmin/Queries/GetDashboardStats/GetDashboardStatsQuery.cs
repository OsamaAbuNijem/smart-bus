using MediatR;

namespace SmartBus.Application.Features.SuperAdmin.Queries.GetDashboardStats;

/// <summary>
/// One-shot aggregate for the SuperAdmin dashboard. Returns every counter
/// the dashboard cards need in a single DB roundtrip so the page paints
/// fast and the JS doesn't have to fan out across half-a-dozen endpoints.
/// </summary>
public record GetDashboardStatsQuery() : IRequest<DashboardStatsDto>;

public record DashboardStatsDto(
    int TotalSchools,
    int SchoolsActiveSub,
    int TotalBuses,
    int TotalDrivers,
    int TotalAssistants,
    int TotalStudents,
    /// <summary>Users currently logged in (LastSeenAt within last 15 min), per role.</summary>
    UsersByRoleDto ActiveUsers,
    /// <summary>Users who used the system at any point today (UTC), per role.</summary>
    UsersByRoleDto TodayUsers,
    TripsTodayDto  Trips
);

/// <summary>Active (not soft-deleted, IsActive where applicable) users per role.</summary>
public record UsersByRoleDto(int Parent, int Driver, int Assistant);

/// <summary>Trip counts for today (UTC), bucketed by status.</summary>
public record TripsTodayDto(int Scheduled, int InProgress, int Completed);
