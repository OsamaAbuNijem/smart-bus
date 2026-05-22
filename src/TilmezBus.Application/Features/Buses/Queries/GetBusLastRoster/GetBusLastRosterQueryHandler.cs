using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Buses.Queries.GetBusLastRoster;

public class GetBusLastRosterQueryHandler
    : IRequestHandler<GetBusLastRosterQuery, Result<List<RosterStudentDto>>>
{
    private readonly IApplicationDbContext _context;

    public GetBusLastRosterQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<List<RosterStudentDto>>> Handle(
        GetBusLastRosterQuery request, CancellationToken ct)
    {
        // Newest non-template trip on this bus + trip-type — irrespective of
        // status (Scheduled / InProgress / Completed). The assistant sees the
        // same kids that rode the previous leg so they don't repick by hand.
        var lastTripId = await _context.Trips
            .Where(t => !t.IsTemplate
                        && t.BusId == request.BusId
                        && t.Type  == request.TripType)
            .OrderByDescending(t => t.ScheduledDeparture)
            .Select(t => (Guid?)t.Id)
            .FirstOrDefaultAsync(ct);

        if (lastTripId is null)
            return Result<List<RosterStudentDto>>.Success(new List<RosterStudentDto>());

        var roster = await _context.StudentTrips
            .Where(st => st.TripId == lastTripId)
            .OrderBy(st => st.Student.FullName)
            .Select(st => new RosterStudentDto(
                st.StudentId,
                st.Student.FullName,
                st.Student.FullNameEn,
                st.Student.Grade))
            .ToListAsync(ct);

        return Result<List<RosterStudentDto>>.Success(roster);
    }
}
