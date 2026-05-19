using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Buses.Queries.GetAllBuses;

namespace TilmezBus.Application.Features.Buses.Queries.GetBusById;

public class GetBusByIdQueryHandler : IRequestHandler<GetBusByIdQuery, Result<BusDto>>
{
    private readonly IApplicationDbContext _context;

    public GetBusByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<BusDto>> Handle(GetBusByIdQuery request, CancellationToken cancellationToken)
    {
        var busEntity = await _context.Buses
            .Where(b => b.Id == request.BusId && !b.IsDeleted)
            .Include(b => b.LastLocation)
            .FirstOrDefaultAsync(cancellationToken);

        if (busEntity is null)
            return Result<BusDto>.Failure($"Bus with ID '{request.BusId}' not found.");

        var schedule = await _context.BusSchedules
            .Where(s => s.BusId == request.BusId)
            .Include(s => s.MorningDriver)
            .Include(s => s.MorningAssistant)
            .FirstOrDefaultAsync(cancellationToken);

        var studentIds = schedule is null
            ? new List<Guid>()
            : await _context.BusScheduleStudents
                .Where(x => x.BusScheduleId == schedule.Id)
                .Select(x => x.StudentId)
                .ToListAsync(cancellationToken);

        var isComplete = schedule is not null
            && schedule.StudentCount > 0
            && schedule.MorningDriverId    is not null
            && schedule.MorningAssistantId is not null
            && schedule.ReturnDriverId     is not null
            && schedule.ReturnAssistantId  is not null;

        var bus = new BusDto(
            busEntity.Id, busEntity.PlateNumber, busEntity.Capacity, busEntity.Status.ToString(),
            schedule?.MorningDriver?.FullName,
            schedule?.MorningAssistant?.FullName,
            schedule?.StudentCount ?? studentIds.Count, studentIds,
            busEntity.LastLocation?.Latitude, busEntity.LastLocation?.Longitude,
            busEntity.CreatedAt,
            isComplete,
            busEntity.QrToken);

        return Result<BusDto>.Success(bus);
    }
}
