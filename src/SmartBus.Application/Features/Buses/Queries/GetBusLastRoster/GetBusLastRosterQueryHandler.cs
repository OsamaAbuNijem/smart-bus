using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Queries.GetBusLastRoster;

public class GetBusLastRosterQueryHandler
    : IRequestHandler<GetBusLastRosterQuery, Result<List<RosterStudentDto>>>
{
    private readonly IApplicationDbContext _context;

    public GetBusLastRosterQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<List<RosterStudentDto>>> Handle(
        GetBusLastRosterQuery request, CancellationToken ct)
    {
        // Most recent non-template trip on this bus + type, regardless of status.
        var lastTrip = await _context.Trips
            .Where(t => !t.IsTemplate
                        && t.BusId == request.BusId
                        && t.Type  == request.TripType)
            .OrderByDescending(t => t.ScheduledDeparture)
            .Select(t => new { t.Id })
            .FirstOrDefaultAsync(ct);

        if (lastTrip is not null)
        {
            var roster = await _context.StudentTrips
                .Where(st => st.TripId == lastTrip.Id)
                .OrderBy(st => st.Student.FullName)
                .Select(st => new RosterStudentDto(
                    st.StudentId,
                    st.Student.FullName,
                    st.Student.FullNameEn,
                    st.Student.Grade))
                .ToListAsync(ct);
            return Result<List<RosterStudentDto>>.Success(roster);
        }

        // Fallback: BusSchedule roster (the canonical assigned students for this bus).
        var fallback = await _context.BusScheduleStudents
            .Where(x => x.BusSchedule.BusId == request.BusId)
            .OrderBy(x => x.Student.FullName)
            .Select(x => new RosterStudentDto(
                x.StudentId,
                x.Student.FullName,
                x.Student.FullNameEn,
                x.Student.Grade))
            .ToListAsync(ct);

        return Result<List<RosterStudentDto>>.Success(fallback);
    }
}
