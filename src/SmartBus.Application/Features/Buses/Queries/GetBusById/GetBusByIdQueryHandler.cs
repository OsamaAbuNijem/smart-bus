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

        var busEntity = await _context.Buses
            .Where(b => b.Id == request.BusId && !b.IsDeleted)
            .Include(b => b.Driver)
            .Include(b => b.AssistantDriver)
            .Include(b => b.LastLocation)
            .FirstOrDefaultAsync(cancellationToken);

        if (busEntity is null)
            return Result<BusDto>.Failure($"Bus with ID '{request.BusId}' not found.");

        var studentIds = await _context.Students
            .Where(s => !s.IsDeleted && s.BusId == request.BusId)
            .Select(s => s.Id)
            .ToListAsync(cancellationToken);

        var bus = new BusDto(
            busEntity.Id, busEntity.PlateNumber, busEntity.Capacity, busEntity.Status.ToString(),
            busEntity.DriverId, busEntity.Driver?.FullName,
            busEntity.AssistantDriverId, busEntity.AssistantDriver?.FullName,
            studentIds.Count, studentIds,
            busEntity.LastLocation?.Latitude, busEntity.LastLocation?.Longitude,
            busEntity.CreatedAt);

        await _cacheService.SetAsync(cacheKey, bus, TimeSpan.FromMinutes(5), cancellationToken);
        return Result<BusDto>.Success(bus);
    }
}
