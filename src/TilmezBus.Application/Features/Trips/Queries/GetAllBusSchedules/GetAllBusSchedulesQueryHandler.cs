using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Trips.Queries.GetAllBusSchedules;

public class GetAllBusSchedulesQueryHandler
    : IRequestHandler<GetAllBusSchedulesQuery, Result<List<BusScheduleSummaryDto>>>
{
    private readonly IApplicationDbContext _context;

    public GetAllBusSchedulesQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<List<BusScheduleSummaryDto>>> Handle(
        GetAllBusSchedulesQuery request, CancellationToken cancellationToken)
    {
        // Join to Bus so we drop schedules whose parent bus has been soft-
        // deleted (orphan rows that previously leaked into the mobile new-
        // trip picker), and so we can scope by the caller's school. Caller-
        // less SuperAdmin calls (SchoolId == null) still see every live row.
        var query =
            from s in _context.BusSchedules
            join b in _context.Buses on s.BusId equals b.Id
            where !b.IsDeleted
            select new { s, b };

        if (request.SchoolId.HasValue)
            query = query.Where(x => x.b.SchoolId == request.SchoolId.Value);

        var schedules = await query
            .Select(x => new BusScheduleSummaryDto(
                x.s.BusId,
                x.s.MorningTime.ToString("HH:mm"),
                x.s.ReturnTime.ToString("HH:mm"),
                x.s.RepeatDays))
            .ToListAsync(cancellationToken);

        return Result<List<BusScheduleSummaryDto>>.Success(schedules);
    }
}
