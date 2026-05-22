using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Buses.Queries.GetBusDefaultDriver;

public class GetBusDefaultDriverQueryHandler
    : IRequestHandler<GetBusDefaultDriverQuery, Result<DefaultDriverDto?>>
{
    private readonly IApplicationDbContext _context;

    public GetBusDefaultDriverQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<DefaultDriverDto?>> Handle(
        GetBusDefaultDriverQuery request, CancellationToken ct)
    {
        // Source of truth is the most recent trip on this (bus, trip-type)
        // — BusSchedules were dropped, so there is no schedule fallback.
        var driver = await _context.Trips
            .Where(t => !t.IsTemplate
                        && t.BusId == request.BusId
                        && t.Type  == request.TripType
                        && t.DriverId != null)
            .OrderByDescending(t => t.ScheduledDeparture)
            .Select(t => t.Driver)
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
