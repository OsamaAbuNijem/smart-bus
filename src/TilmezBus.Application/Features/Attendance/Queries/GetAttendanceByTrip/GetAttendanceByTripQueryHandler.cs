using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Attendance.Queries.GetAttendanceByTrip;

public class GetAttendanceByTripQueryHandler : IRequestHandler<GetAttendanceByTripQuery, Result<IReadOnlyList<TripAttendanceDto>>>
{
    private readonly IApplicationDbContext _context;

    public GetAttendanceByTripQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<IReadOnlyList<TripAttendanceDto>>> Handle(GetAttendanceByTripQuery request, CancellationToken cancellationToken)
    {
        var items = await _context.Attendances
            .Where(a => a.TripId == request.TripId && !a.IsDeleted)
            .Include(a => a.Student)
            .OrderBy(a => a.Student.FullName)
            .Select(a => new TripAttendanceDto(a.StudentId, a.Student.FullName, a.Student.Grade, a.Status, a.BoardingTime))
            .ToListAsync(cancellationToken);

        return Result<IReadOnlyList<TripAttendanceDto>>.Success(items);
    }
}
