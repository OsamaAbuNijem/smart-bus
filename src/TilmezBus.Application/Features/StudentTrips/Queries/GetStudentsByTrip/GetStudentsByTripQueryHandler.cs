using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.StudentTrips.Queries.GetStudentsByTrip;

public class GetStudentsByTripQueryHandler : IRequestHandler<GetStudentsByTripQuery, Result<IReadOnlyList<StudentTripDto>>>
{
    private readonly IApplicationDbContext _context;

    public GetStudentsByTripQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<IReadOnlyList<StudentTripDto>>> Handle(GetStudentsByTripQuery request, CancellationToken cancellationToken)
    {
        var items = await _context.StudentTrips
            .Where(st => st.TripId == request.TripId && !st.IsDeleted)
            .Include(st => st.Student)
            .OrderBy(st => st.Student.FullName)
            .Select(st => new StudentTripDto(st.StudentId, st.Student.FullName, st.Student.Grade, st.BoardingStatus, st.BoardingTime))
            .ToListAsync(cancellationToken);

        return Result<IReadOnlyList<StudentTripDto>>.Success(items);
    }
}
