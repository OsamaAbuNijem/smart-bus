using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.SuperAdmin.Queries.GetDashboardStats;

public class GetDashboardStatsQueryHandler : IRequestHandler<GetDashboardStatsQuery, DashboardStatsDto>
{
    /// <summary>
    /// "Active right now" window. A user is considered logged in if they've
    /// pinged any authenticated endpoint within this span — LastSeenAt is
    /// stamped by API middleware (throttled). 15 minutes balances recency
    /// against idle-but-still-using-the-app users.
    /// </summary>
    private static readonly TimeSpan ActiveWindow = TimeSpan.FromMinutes(15);

    private readonly IApplicationDbContext _context;
    private readonly IUserStore _userStore;

    public GetDashboardStatsQueryHandler(IApplicationDbContext context, IUserStore userStore)
    {
        _context   = context;
        _userStore = userStore;
    }

    public async Task<DashboardStatsDto> Handle(GetDashboardStatsQuery request, CancellationToken cancellationToken)
    {
        var now      = DateTime.UtcNow;
        var dayStart = now.Date;
        var dayEnd   = dayStart.AddDays(1);

        // Total schools (soft-delete aware).
        var totalSchools = await _context.Schools
            .CountAsync(s => !s.IsDeleted, cancellationToken);

        // Schools whose latest subscription is currently live. We count
        // distinct schools (not subs) so a school with overlapping rows
        // still contributes once.
        var schoolsActiveSub = await _context.Subscriptions
            .Where(sub => !sub.IsDeleted && sub.IsActive
                       && sub.ActivationDate <= now
                       && sub.ExpirationDate >= now)
            .Select(sub => sub.SchoolId)
            .Distinct()
            .CountAsync(cancellationToken);

        // Buses / drivers / assistants / students — soft-delete aware.
        // Assistants share the Drivers table via a DriverType discriminator;
        // counting them separately matches how the rest of the app surfaces
        // the two populations.
        var totalBuses      = await _context.Buses.CountAsync(b => !b.IsDeleted, cancellationToken);
        var totalDrivers    = await _context.Drivers.CountAsync(d => !d.IsDeleted && d.DriverType == DriverType.Driver,    cancellationToken);
        var totalAssistants = await _context.Drivers.CountAsync(d => !d.IsDeleted && d.DriverType == DriverType.Assistant, cancellationToken);
        var totalStudents   = await _context.Students.CountAsync(s => !s.IsDeleted, cancellationToken);

        // Active user counts per role mean "currently logged in" — users
        // whose ApplicationUser.LastSeenAt is within ActiveWindow. The
        // LastSeenTrackingMiddleware in the API stamps that column on each
        // authenticated request.
        var activeParents    = await _userStore.CountActiveUsersByRoleAsync("Parent",    ActiveWindow, cancellationToken);
        var activeDrivers    = await _userStore.CountActiveUsersByRoleAsync("Driver",    ActiveWindow, cancellationToken);
        var activeAssistants = await _userStore.CountActiveUsersByRoleAsync("Assistant", ActiveWindow, cancellationToken);

        // "Used today" = users with at least one authenticated request since
        // UTC midnight. Reuses the same LastSeenAt column but with a window
        // that stretches back to today's start.
        var todayWindow      = DateTime.UtcNow - dayStart;
        var todayParents     = await _userStore.CountActiveUsersByRoleAsync("Parent",    todayWindow, cancellationToken);
        var todayDrivers     = await _userStore.CountActiveUsersByRoleAsync("Driver",    todayWindow, cancellationToken);
        var todayAssistants  = await _userStore.CountActiveUsersByRoleAsync("Assistant", todayWindow, cancellationToken);

        // Today's trips (excluding the recurring schedule templates), split
        // by Status. ScheduledDeparture is the canonical "trip day" — same
        // filter the admin dashboard uses.
        var tripsTodayQuery = _context.Trips
            .Where(t => !t.IsDeleted
                     && !t.IsTemplate
                     && t.ScheduledDeparture >= dayStart
                     && t.ScheduledDeparture <  dayEnd);
        var tripsScheduled  = await tripsTodayQuery.CountAsync(t => t.Status == TripStatus.Scheduled,  cancellationToken);
        var tripsInProgress = await tripsTodayQuery.CountAsync(t => t.Status == TripStatus.InProgress, cancellationToken);
        var tripsCompleted  = await tripsTodayQuery.CountAsync(t => t.Status == TripStatus.Completed,  cancellationToken);

        return new DashboardStatsDto(
            TotalSchools:     totalSchools,
            SchoolsActiveSub: schoolsActiveSub,
            TotalBuses:       totalBuses,
            TotalDrivers:     totalDrivers,
            TotalAssistants:  totalAssistants,
            TotalStudents:    totalStudents,
            ActiveUsers: new UsersByRoleDto(
                Parent:    activeParents,
                Driver:    activeDrivers,
                Assistant: activeAssistants),
            TodayUsers: new UsersByRoleDto(
                Parent:    todayParents,
                Driver:    todayDrivers,
                Assistant: todayAssistants),
            Trips: new TripsTodayDto(
                Scheduled:  tripsScheduled,
                InProgress: tripsInProgress,
                Completed:  tripsCompleted));
    }
}
