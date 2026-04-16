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
            .Include(b => b.LastLocation);

        var totalCount = await query.CountAsync(cancellationToken);
        var buses = await query
            .OrderByDescending(b => b.CreatedAt)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(b => new BusDto(
                b.Id,
                b.PlateNumber,
                b.Model,
                b.Capacity,
                b.Status.ToString(),
                b.Driver != null ? b.Driver.FullName : null,
                b.LastLocation != null ? b.LastLocation.Latitude : null,
                b.LastLocation != null ? b.LastLocation.Longitude : null,
                b.CreatedAt))
            .ToListAsync(cancellationToken);

        var result = PagedResult<BusDto>.Create(buses, totalCount, request.PageNumber, request.PageSize);
        await _cacheService.SetAsync(cacheKey, result, TimeSpan.FromMinutes(2), cancellationToken);

        return result;
    }
}
