using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Queries.GetAllBuses;

public class GetAllBusesQueryHandler : IRequestHandler<GetAllBusesQuery, PagedResult<BusDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICacheService _cacheService;

    public GetAllBusesQueryHandler(IApplicationDbContext context, ICacheService cacheService)
    {
        _context = context;
        _cacheService = cacheService;
    }

    public async Task<PagedResult<BusDto>> Handle(GetAllBusesQuery request, CancellationToken cancellationToken)
    {
        var cacheKey = $"buses:page:{request.PageNumber}:size:{request.PageSize}";
        var cached = await _cacheService.GetAsync<PagedResult<BusDto>>(cacheKey, cancellationToken);
        if (cached is not null) return cached;

        var query = _context.Buses
            .Where(b => !b.IsDeleted)
            .Include(b => b.Driver)
            .Include(b => b.AssistantDriver)
            .Include(b => b.LastLocation);

        var totalCount = await query.CountAsync(cancellationToken);

        var busEntities = await query
            .OrderByDescending(b => b.CreatedAt)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        var busIds = busEntities.Select(b => b.Id).ToList();
        var studentsByBus = await _context.Students
            .Where(s => !s.IsDeleted && s.BusId != null && busIds.Contains(s.BusId!.Value))
            .GroupBy(s => s.BusId!.Value)
            .Select(g => new { BusId = g.Key, Ids = g.Select(s => s.Id).ToList(), Count = g.Count() })
            .ToListAsync(cancellationToken);

        var buses = busEntities.Select(b => {
            var sg = studentsByBus.FirstOrDefault(x => x.BusId == b.Id);
            return new BusDto(
                b.Id, b.PlateNumber, b.Capacity, b.Status.ToString(),
                b.DriverId, b.Driver?.FullName,
                b.AssistantDriverId, b.AssistantDriver?.FullName,
                sg?.Count ?? 0, (IReadOnlyList<Guid>)(sg?.Ids ?? new List<Guid>()),
                b.LastLocation?.Latitude, b.LastLocation?.Longitude,
                b.CreatedAt);
        }).ToList();

        var result = PagedResult<BusDto>.Create(buses, totalCount, request.PageNumber, request.PageSize);
        await _cacheService.SetAsync(cacheKey, result, TimeSpan.FromMinutes(2), cancellationToken);

        return result;
    }
}
