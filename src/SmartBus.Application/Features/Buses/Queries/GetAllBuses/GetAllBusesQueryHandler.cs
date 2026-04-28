using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Queries.GetAllBuses;

public class GetAllBusesQueryHandler : IRequestHandler<GetAllBusesQuery, PagedResult<BusDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllBusesQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<BusDto>> Handle(GetAllBusesQuery request, CancellationToken cancellationToken)
    {
        var baseQuery = _context.Buses
            .Where(b => !b.IsDeleted)
            .Include(b => b.LastLocation)
            .AsQueryable();

        // Plate-number filter (substring, case-insensitive).
        if (!string.IsNullOrWhiteSpace(request.PlateNumber))
        {
            var plate = request.PlateNumber.Trim();
            baseQuery = baseQuery.Where(b => EF.Functions.Like(b.PlateNumber, $"%{plate}%"));
        }

        // Driver/assistant-name filter: any of the 4 schedule slots has a matching Driver.FullName.
        if (!string.IsNullOrWhiteSpace(request.PersonName))
        {
            var name = request.PersonName.Trim();
            baseQuery = baseQuery.Where(b =>
                _context.BusSchedules.Any(s => s.BusId == b.Id && !s.IsDeleted && (
                    (s.MorningDriver    != null && EF.Functions.Like(s.MorningDriver.FullName,    $"%{name}%")) ||
                    (s.MorningAssistant != null && EF.Functions.Like(s.MorningAssistant.FullName, $"%{name}%")) ||
                    (s.ReturnDriver     != null && EF.Functions.Like(s.ReturnDriver.FullName,     $"%{name}%")) ||
                    (s.ReturnAssistant  != null && EF.Functions.Like(s.ReturnAssistant.FullName,  $"%{name}%"))
                )));
        }

        var totalCount = await baseQuery.CountAsync(cancellationToken);

        var busEntities = await baseQuery
            .OrderByDescending(b => b.CreatedAt)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        var busIds = busEntities.Select(b => b.Id).ToList();

        var schedules = await _context.BusSchedules
            .Where(s => busIds.Contains(s.BusId))
            .Include(s => s.MorningDriver)
            .Include(s => s.MorningAssistant)
            .Select(s => new
            {
                s.BusId,
                MorningDriverName    = s.MorningDriver != null ? s.MorningDriver.FullName : null,
                MorningAssistantName = s.MorningAssistant != null ? s.MorningAssistant.FullName : null,
                s.StudentCount,
                HasAllAssignments =
                    s.MorningDriverId    != null &&
                    s.MorningAssistantId != null &&
                    s.ReturnDriverId     != null &&
                    s.ReturnAssistantId  != null &&
                    s.StudentCount > 0
            })
            .ToListAsync(cancellationToken);

        var studentsByBus = await _context.BusScheduleStudents
            .Where(x => busIds.Contains(x.BusSchedule.BusId))
            .Select(x => new { x.BusSchedule.BusId, x.StudentId })
            .ToListAsync(cancellationToken);

        var idsByBus = studentsByBus
            .GroupBy(x => x.BusId)
            .ToDictionary(g => g.Key, g => (IReadOnlyList<Guid>)g.Select(x => x.StudentId).ToList());

        var buses = busEntities.Select(b => {
            var sched = schedules.FirstOrDefault(x => x.BusId == b.Id);
            idsByBus.TryGetValue(b.Id, out var ids);
            return new BusDto(
                b.Id, b.PlateNumber, b.Capacity, b.Status.ToString(),
                sched?.MorningDriverName,
                sched?.MorningAssistantName,
                sched?.StudentCount ?? 0,
                ids ?? Array.Empty<Guid>(),
                b.LastLocation?.Latitude, b.LastLocation?.Longitude,
                b.CreatedAt,
                sched?.HasAllAssignments ?? false,
                b.QrToken);
        }).ToList();

        return PagedResult<BusDto>.Create(buses, totalCount, request.PageNumber, request.PageSize);
    }
}
