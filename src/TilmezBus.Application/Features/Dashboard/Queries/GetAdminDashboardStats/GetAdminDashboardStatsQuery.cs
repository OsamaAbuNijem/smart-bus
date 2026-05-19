using MediatR;

namespace TilmezBus.Application.Features.Dashboard.Queries.GetAdminDashboardStats;

/// <summary>
/// One-shot aggregate for the school-admin dashboard. Scoped to a single
/// school so a tenant only sees its own counts. All today buckets use the
/// trip's ScheduledDeparture for "today" — same convention the admin trips
/// page and TodayTrips partial use.
/// </summary>
public record GetAdminDashboardStatsQuery(Guid SchoolId) : IRequest<AdminDashboardStatsDto>;

public record AdminDashboardStatsDto(
    int TotalStudents,
    int TotalBuses,
    int TotalDrivers,
    int TotalAssistants,
    int TotalTrips,
    TripsBreakdownDto Today,
    TripsBreakdownDto Morning,
    TripsBreakdownDto Return);

/// <summary>
/// Numbers for a single trip-type slice on today's date.
///   Trips    = trip count
///   Students = StudentTrip rows on those trips (roster total)
///   Absent   = StudentTrip rows with BoardingStatus = Absent
/// </summary>
public record TripsBreakdownDto(int Trips, int Students, int Absent);
