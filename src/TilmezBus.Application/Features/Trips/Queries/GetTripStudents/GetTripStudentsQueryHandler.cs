using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Trips.Queries.GetTripStudents;

public class GetTripStudentsQueryHandler
    : IRequestHandler<GetTripStudentsQuery, Result<List<TripStudentDto>>>
{
    private readonly IApplicationDbContext _context;

    public GetTripStudentsQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<List<TripStudentDto>>> Handle(
        GetTripStudentsQuery request, CancellationToken cancellationToken)
    {
        var trip = await _context.Trips
            .FirstOrDefaultAsync(t => t.Id == request.TripId, cancellationToken);

        if (trip is null)
            return Result<List<TripStudentDto>>.Failure("الرحلة غير موجودة");

        // Primary: StudentTrip rows for this trip (global filter handles IsDeleted)
        var studentTrips = await _context.StudentTrips
            .Where(st => st.TripId == request.TripId)
            .Include(st => st.Student)
            .OrderBy(st => st.Student.FullName)
            .Select(st => new TripStudentDto(
                st.StudentId,
                st.Student.FullName,
                st.Student.Grade,
                st.Student.HomeArea,
                st.BoardingStatus.ToString(),
                st.BoardingTime,
                st.DropoffTime))
            .ToListAsync(cancellationToken);

        // Fallback: no StudentTrip rows yet — show schedule-assigned students as Waiting
        if (studentTrips.Count == 0)
        {
            studentTrips = await _context.BusScheduleStudents
                .Where(x => x.BusSchedule.BusId == trip.BusId)
                .Select(x => x.Student)
                .Where(s => !s.IsDeleted)
                .OrderBy(s => s.FullName)
                .Select(s => new TripStudentDto(
                    s.Id,
                    s.FullName,
                    s.Grade,
                    s.HomeArea,
                    "Waiting",
                    null,
                    null))
                .ToListAsync(cancellationToken);
        }

        return Result<List<TripStudentDto>>.Success(studentTrips);
    }
}
