using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;

namespace SmartBus.Application.Features.Buses.Queries.GetBusById;

public class GetBusByIdQueryHandler : IRequestHandler<GetBusByIdQuery, Result<BusDto>>
{
    private readonly IApplicationDbContext _context;

    public GetBusByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<BusDto>> Handle(GetBusByIdQuery request, CancellationToken cancellationToken)
    {
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

        return Result<BusDto>.Success(bus);
    }
}
