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
        // The BusSchedule row holds the assigned driver for each leg —
        // morning vs. return — picked when the admin set up the schedule.
        var driver = await _context.BusSchedules
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
