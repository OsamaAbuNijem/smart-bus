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

        // StudentTrip rows are the single source of truth — BusSchedule
        // fallback is gone with the table.
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

        return Result<List<TripStudentDto>>.Success(studentTrips);
    }
}
