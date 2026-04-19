using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Queries.GetAllBusSchedules;

public class GetAllBusSchedulesQueryHandler
    : IRequestHandler<GetAllBusSchedulesQuery, Result<List<BusScheduleSummaryDto>>>
{
    private readonly IApplicationDbContext _context;

    public GetAllBusSchedulesQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<List<BusScheduleSummaryDto>>> Handle(
        GetAllBusSchedulesQuery request, CancellationToken cancellationToken)
    {
        var schedules = await _context.BusSchedules
            .Select(s => new BusScheduleSummaryDto(
                s.BusId,
                s.MorningTime.ToString("HH:mm"),
                s.ReturnTime.ToString("HH:mm"),
                s.RepeatDays))
            .ToListAsync(cancellationToken);

        return Result<List<BusScheduleSummaryDto>>.Success(schedules);
    }
}
