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

        // BusSchedule was the old "this bus has these students + this driver"
        // registry. Schedules were removed; drivers/assistants are assigned
        // per trip on scan, and the roster is whoever the assistant adds
        // during trip setup. The DTO fields are kept (for backward compat
        // with the admin web list) but always null/empty now.
        var bus = new BusDto(
            busEntity.Id, busEntity.PlateNumber, busEntity.Capacity, busEntity.Status.ToString(),
            DriverName:          null,
            AssistantDriverName: null,
            StudentCount: 0,
            StudentIds:   new List<Guid>(),
            busEntity.LastLocation?.Latitude, busEntity.LastLocation?.Longitude,
            busEntity.CreatedAt,
            IsScheduleComplete: false,
            busEntity.QrToken);

        return Result<BusDto>.Success(bus);
    }
}
