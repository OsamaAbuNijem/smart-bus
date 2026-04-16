using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;

namespace SmartBus.Application.Features.Buses.Queries.GetBusById;

public class GetBusByIdQueryHandler : IRequestHandler<GetBusByIdQuery, Result<BusDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICacheService _cacheService;

    public GetBusByIdQueryHandler(IApplicationDbContext context, ICacheService cacheService)
    {
        _context = context;
        _cacheService = cacheService;
    }

    public async Task<Result<BusDto>> Handle(GetBusByIdQuery request, CancellationToken cancellationToken)
    {
        var cacheKey = $"bus:{request.BusId}";
        var cached = await _cacheService.GetAsync<BusDto>(cacheKey, cancellationToken);
        if (cached is not null) return Result<BusDto>.Success(cached);

        var bus = await _context.Buses
            .Where(b => b.Id == request.BusId && !b.IsDeleted)
            .Include(b => b.Driver)
            .Include(b => b.LastLocation)
            .Select(b => new BusDto(
                b.Id, b.PlateNumber, b.Model, b.Capacity, b.Status.ToString(),
                b.Driver != null ? b.Driver.FullName : null,
                b.LastLocation != null ? b.LastLocation.Latitude : null,
                b.LastLocation != null ? b.LastLocation.Longitude : null,
                b.CreatedAt))
            .FirstOrDefaultAsync(cancellationToken);

        if (bus is null)
            return Result<BusDto>.Failure($"Bus with ID '{request.BusId}' not found.");

        await _cacheService.SetAsync(cacheKey, bus, TimeSpan.FromMinutes(5), cancellationToken);
        return Result<BusDto>.Success(bus);
    }
}
