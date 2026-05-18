using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Buses.Queries.GetBusDefaultDriver;

public class GetBusDefaultDriverQueryHandler
    : IRequestHandler<GetBusDefaultDriverQuery, Result<DefaultDriverDto?>>
{
    private readonly IApplicationDbContext _context;

    public GetBusDefaultDriverQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<DefaultDriverDto?>> Handle(
        GetBusDefaultDriverQuery request, CancellationToken ct)
    {
        // Prefer the driver from the most recent trip on (bus, type) so the
        // assistant sees the same person they used last time. Falls back to
        // the BusSchedule assignment when no prior trip exists.
        var lastTripDriver = await _context.Trips
            .Where(t => !t.IsTemplate
                        && t.BusId    == request.BusId
                        && t.Type     == request.TripType
                        && t.DriverId != null)
            .OrderByDescending(t => t.ScheduledDeparture)
            .Select(t => t.Driver)
            .FirstOrDefaultAsync(ct);

        var driver = lastTripDriver
            ?? await _context.BusSchedules
                .Where(s => s.BusId == request.BusId)
                .Select(s => request.TripType == TripType.Morning
                    ? s.MorningDriver
                    : s.ReturnDriver)
                .FirstOrDefaultAsync(ct);

        if (driver is null || driver.DriverType != DriverType.Driver)
            return Result<DefaultDriverDto?>.Success(null);

        return Result<DefaultDriverDto?>.Success(new DefaultDriverDto(
            driver.Id,
            driver.FullName,
            driver.PhoneNumber,
            driver.DriverType.ToString()));
    }
}
