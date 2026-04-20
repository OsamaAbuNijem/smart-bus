using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Queries.GetAllTrips;

public class GetAllTripsQueryHandler : IRequestHandler<GetAllTripsQuery, PagedResult<TripDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllTripsQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<PagedResult<TripDto>> Handle(GetAllTripsQuery request, CancellationToken cancellationToken)
    {
        // Join trip → schedule (per-bus). Driver/assistant names are taken from the schedule
        // side matching the trip type (Morning/Return).
        var query =
            from t in _context.Trips
            where !t.IsDeleted && !t.IsTemplate
            from sched in _context.BusSchedules.Where(s => s.BusId == t.BusId).DefaultIfEmpty()
            from morningDriver    in _context.Drivers.Where(d => sched != null && d.Id == sched.MorningDriverId).DefaultIfEmpty()
            from morningAssistant in _context.Drivers.Where(d => sched != null && d.Id == sched.MorningAssistantId).DefaultIfEmpty()
            from returnDriver     in _context.Drivers.Where(d => sched != null && d.Id == sched.ReturnDriverId).DefaultIfEmpty()
            from returnAssistant  in _context.Drivers.Where(d => sched != null && d.Id == sched.ReturnAssistantId).DefaultIfEmpty()
            select new
            {
                Trip              = t,
                Bus               = t.Bus,
                Route             = t.Route,
                MorningDriverName    = morningDriver    != null ? morningDriver.FullName    : null,
                MorningAssistantName = morningAssistant != null ? morningAssistant.FullName : null,
                ReturnDriverName     = returnDriver     != null ? returnDriver.FullName     : null,
                ReturnAssistantName  = returnAssistant  != null ? returnAssistant.FullName  : null
            };

        // Filter by driver or assistant name
        if (!string.IsNullOrWhiteSpace(request.PersonName))
        {
            var name = request.PersonName.Trim();
            query = query.Where(x =>
                (x.MorningDriverName    != null && x.MorningDriverName.Contains(name)) ||
                (x.MorningAssistantName != null && x.MorningAssistantName.Contains(name)) ||
                (x.ReturnDriverName     != null && x.ReturnDriverName.Contains(name))    ||
                (x.ReturnAssistantName  != null && x.ReturnAssistantName.Contains(name)));
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
                x.Route != null ? x.Route.Name : null,
                x.Trip.Type.ToString(),
                x.Trip.ScheduledDeparture,
                x.Trip.ActualDeparture,
                x.Trip.ActualArrival,
                x.Trip.Status.ToString(),
                x.Trip.RepeatDays,
                x.Trip.Type == TripType.Morning ? x.MorningDriverName    : x.ReturnDriverName,
                x.Trip.Type == TripType.Morning ? x.MorningAssistantName : x.ReturnAssistantName))
            .ToListAsync(cancellationToken);

        return PagedResult<TripDto>.Create(trips, totalCount, request.PageNumber, request.PageSize);
    }
}
