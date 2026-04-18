using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Queries.GetBusSchedule;

public class GetBusScheduleQueryHandler : IRequestHandler<GetBusScheduleQuery, Result<BusScheduleDto>>
{
    private readonly IApplicationDbContext _context;

    public GetBusScheduleQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<BusScheduleDto>> Handle(GetBusScheduleQuery request, CancellationToken cancellationToken)
    {
        var schedule = await _context.BusSchedules
            .FirstOrDefaultAsync(s => s.BusId == request.BusId, cancellationToken);

        if (schedule is null)
            return Result<BusScheduleDto>.Success(new BusScheduleDto(null, null, 0));

        return Result<BusScheduleDto>.Success(new BusScheduleDto(
            schedule.MorningTime.ToString("HH:mm"),
            schedule.ReturnTime.ToString("HH:mm"),
            schedule.RepeatDays
        ));
    }
}
