using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.AbsenceRequests.Queries.GetAbsenceRequestsByStudent;

public class GetAbsenceRequestsByStudentQueryHandler : IRequestHandler<GetAbsenceRequestsByStudentQuery, Result<IReadOnlyList<AbsenceRequestDto>>>
{
    private readonly IApplicationDbContext _context;

    public GetAbsenceRequestsByStudentQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<IReadOnlyList<AbsenceRequestDto>>> Handle(GetAbsenceRequestsByStudentQuery request, CancellationToken cancellationToken)
    {
        var rows = await _context.AbsenceRequests
            .Where(a => a.StudentId == request.StudentId && !a.IsDeleted)
            .Include(a => a.Student)
            .OrderByDescending(a => a.Date)
            .Select(a => new
            {
                a.Id,
                a.StudentId,
                a.Student.FullName,
                a.Date,
                a.TripType,
                a.Reason,
                a.Status,
                a.CreatedAt
            })
            .ToListAsync(cancellationToken);

        if (rows.Count == 0)
        {
            return Result<IReadOnlyList<AbsenceRequestDto>>.Success(
                Array.Empty<AbsenceRequestDto>());
        }

        // Pull every non-Scheduled trip for the days these requests cover, so
        // we can flip CanCancel = false once the matching leg actually starts.
        // Filtering by date range first keeps this cheap regardless of how
        // long the absence history is.
        var minDate = rows.Min(r => r.Date);
        var maxDate = rows.Max(r => r.Date);
        var minStartUtc = minDate.ToDateTime(TimeOnly.MinValue).ToUniversalTime();
        var maxEndUtc = maxDate.ToDateTime(TimeOnly.MinValue)
            .AddDays(1).ToUniversalTime();

        var startedTrips = await _context.StudentTrips
            .Where(st => st.StudentId == request.StudentId
                         && !st.Trip.IsTemplate
                         && st.Trip.Status != TripStatus.Scheduled
                         && st.Trip.ScheduledDeparture >= minStartUtc
                         && st.Trip.ScheduledDeparture <  maxEndUtc)
            .Select(st => new
            {
                Date = DateOnly.FromDateTime(st.Trip.ScheduledDeparture),
                st.Trip.Type,
            })
            .ToListAsync(cancellationToken);

        var items = rows.Select(r =>
        {
            var conflicts = startedTrips.Any(t =>
                t.Date == r.Date &&
                (r.TripType == AbsenceTripType.FullDay ||
                 (r.TripType == AbsenceTripType.MorningOnly && t.Type == TripType.Morning) ||
                 (r.TripType == AbsenceTripType.ReturnOnly  && t.Type == TripType.Return)));
            return new AbsenceRequestDto(
                r.Id, r.StudentId, r.FullName, r.Date,
                r.TripType, r.Reason, r.Status, r.CreatedAt,
                !conflicts);
        }).ToList();

        return Result<IReadOnlyList<AbsenceRequestDto>>.Success(items);
    }
}
