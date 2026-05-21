using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Queries.GetAllTrips;

public class GetAllTripsQueryHandler : IRequestHandler<GetAllTripsQuery, PagedResult<TripDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllTripsQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<PagedResult<TripDto>> Handle(GetAllTripsQuery request, CancellationToken cancellationToken)
    {
        // Prefer driver/assistant stamped on the trip itself (set when the
        // assistant materialises the trip in the mobile flow). Fall back to
        // the bus schedule's morning/return slot for legacy trips that
        // pre-date Trip.DriverId / Trip.AssistantId.
        // Exclude trips whose Bus has been soft-deleted — otherwise the count (which
        // doesn't traverse the nav) won't match the rendered rows (where the Bus
        // query filter hides soft-deleted buses and their trips become orphans).
        // BusSchedule fallback removed — driver/assistant come purely from
        // Trip.DriverId / Trip.AssistantId (set by ScanBusQr / StartTrip).
        var query =
            from t in _context.Trips
            where !t.IsDeleted && !t.IsTemplate && t.Bus != null
            from tripDriver    in _context.Drivers.Where(d => d.Id == t.DriverId).DefaultIfEmpty()
            from tripAssistant in _context.Drivers.Where(d => d.Id == t.AssistantId).DefaultIfEmpty()
            select new
            {
                Trip          = t,
                Bus           = t.Bus,
                DriverName    = tripDriver    != null ? tripDriver.FullName    : null,
                AssistantName = tripAssistant != null ? tripAssistant.FullName : null,
            };

        // Filter by driver or assistant name
        if (!string.IsNullOrWhiteSpace(request.PersonName))
        {
            var name = request.PersonName.Trim();
            query = query.Where(x =>
                (x.DriverName    != null && x.DriverName.Contains(name)) ||
                (x.AssistantName != null && x.AssistantName.Contains(name)));
        }

        // Filter by bus plate number (partial match, case-insensitive via LOWER).
        if (!string.IsNullOrWhiteSpace(request.BusPlateNumber))
        {
            var plate = request.BusPlateNumber.Trim().ToLower();
            query = query.Where(x => x.Bus.PlateNumber.ToLower().Contains(plate));
        }

        // Filter by date
        if (request.Date.HasValue)
        {
            var day    = request.Date.Value.ToDateTime(TimeOnly.MinValue);
            var dayEnd = day.AddDays(1);
            query = query.Where(x => x.Trip.ScheduledDeparture >= day && x.Trip.ScheduledDeparture < dayEnd);
        }

        // Filter by status
        if (!string.IsNullOrWhiteSpace(request.Status) &&
            Enum.TryParse<TripStatus>(request.Status, ignoreCase: true, out var status))
        {
            query = query.Where(x => x.Trip.Status == status);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var trips = await query
            .OrderByDescending(x => x.Trip.ScheduledDeparture)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(x => new TripDto(
                x.Trip.Id,
                x.Trip.BusId,
                x.Bus.PlateNumber,
                null,
                x.Trip.Type.ToString(),
                x.Trip.ScheduledDeparture,
                x.Trip.ActualDeparture,
                x.Trip.ActualArrival,
                x.Trip.Status.ToString(),
                x.Trip.RepeatDays,
                x.DriverName,
                x.AssistantName))
            .ToListAsync(cancellationToken);

        return PagedResult<TripDto>.Create(trips, totalCount, request.PageNumber, request.PageSize);
    }
}
