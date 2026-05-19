using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Dashboard.Queries.GetAdminDashboardStats;

public class GetAdminDashboardStatsQueryHandler
    : IRequestHandler<GetAdminDashboardStatsQuery, AdminDashboardStatsDto>
{
    private readonly IApplicationDbContext _context;

    public GetAdminDashboardStatsQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<AdminDashboardStatsDto> Handle(GetAdminDashboardStatsQuery request, CancellationToken cancellationToken)
    {
        var schoolId       = request.SchoolId;
        var schoolIdString = schoolId.ToString();
        var now            = DateTime.UtcNow;
        var dayStart       = now.Date;
        var dayEnd         = dayStart.AddDays(1);

        // Total students mirrors GetAllStudents: only count those linked to a
        // currently-live subscription for this school. Keeps the dashboard
        // tile in sync with the students grid.
        var activeStudentIds = _context.SubscriptionStudents
            .Where(x => x.Subscription!.SchoolId == schoolId
                     && x.Subscription.IsActive
                     && x.Subscription.ActivationDate <= now
                     && x.Subscription.ExpirationDate >= now
                     && !x.Subscription.IsDeleted
                     && !x.Student!.IsDeleted)
            .Select(x => x.StudentId);

        var totalStudents = await _context.Students
            .Where(s => !s.IsDeleted && s.SchoolId == schoolIdString)
            .Where(s => activeStudentIds.Contains(s.Id))
            .CountAsync(cancellationToken);

        var totalBuses      = await _context.Buses
            .CountAsync(b => !b.IsDeleted && b.SchoolId == schoolId, cancellationToken);
        var totalDrivers    = await _context.Drivers
            .CountAsync(d => !d.IsDeleted && d.SchoolId == schoolId && d.DriverType == DriverType.Driver, cancellationToken);
        var totalAssistants = await _context.Drivers
            .CountAsync(d => !d.IsDeleted && d.SchoolId == schoolId && d.DriverType == DriverType.Assistant, cancellationToken);

        // Trips count excludes the recurring schedule templates — same filter
        // GetAllTrips uses so the "TotalTrips" tile matches the trips grid.
        // School scope is taken from the Bus (every trip has a BusId, and
        // Bus.SchoolId is the source of truth). Trip.SchoolId is also
        // denormalized on some create paths but not all, so we deliberately
        // avoid it here.
        var totalTrips = await _context.Trips
            .CountAsync(t => !t.IsDeleted && !t.IsTemplate && t.Bus != null && t.Bus.SchoolId == schoolId, cancellationToken);

        // Today's concrete trips for this school. We snapshot the Ids here
        // and reuse them for the StudentTrip counts so the three buckets
        // (Today/Morning/Return) share one source of truth.
        var todayTrips = await _context.Trips
            .Where(t => !t.IsDeleted
                     && !t.IsTemplate
                     && t.Bus != null && t.Bus.SchoolId == schoolId
                     && t.ScheduledDeparture >= dayStart
                     && t.ScheduledDeparture <  dayEnd)
            .Select(t => new { t.Id, t.Type })
            .ToListAsync(cancellationToken);

        var todayIds   = todayTrips.Select(t => t.Id).ToList();
        var morningIds = todayTrips.Where(t => t.Type == TripType.Morning).Select(t => t.Id).ToList();
        var returnIds  = todayTrips.Where(t => t.Type == TripType.Return ).Select(t => t.Id).ToList();

        var today   = await BuildBreakdownAsync(todayIds,   cancellationToken);
        var morning = await BuildBreakdownAsync(morningIds, cancellationToken);
        var ret     = await BuildBreakdownAsync(returnIds,  cancellationToken);

        return new AdminDashboardStatsDto(
            TotalStudents:   totalStudents,
            TotalBuses:      totalBuses,
            TotalDrivers:    totalDrivers,
            TotalAssistants: totalAssistants,
            TotalTrips:      totalTrips,
            Today:           today,
            Morning:         morning,
            Return:          ret);
    }

    private async Task<TripsBreakdownDto> BuildBreakdownAsync(
        IReadOnlyCollection<Guid> tripIds, CancellationToken cancellationToken)
    {
        if (tripIds.Count == 0)
            return new TripsBreakdownDto(0, 0, 0);

        var roster = _context.StudentTrips.Where(st => !st.IsDeleted && tripIds.Contains(st.TripId));
        var students = await roster.CountAsync(cancellationToken);
        var absent   = await roster.CountAsync(st => st.BoardingStatus == BoardingStatus.Absent, cancellationToken);

        return new TripsBreakdownDto(Trips: tripIds.Count, Students: students, Absent: absent);
    }
}
