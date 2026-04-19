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
        var query = _context.Trips
            .Where(t => !t.IsDeleted && !t.IsTemplate)
            .Include(t => t.Bus).ThenInclude(b => b.Driver)
            .Include(t => t.Bus).ThenInclude(b => b.AssistantDriver)
            .Include(t => t.Route)
            .AsQueryable();

        // Filter by driver or assistant name
        if (!string.IsNullOrWhiteSpace(request.PersonName))
        {
            var name = request.PersonName.Trim();
            query = query.Where(t =>
                (t.Bus.Driver != null && t.Bus.Driver.FullName.Contains(name)) ||
                (t.Bus.AssistantDriver != null && t.Bus.AssistantDriver.FullName.Contains(name)));
        }

        // Filter by date (match on the date portion of ScheduledDeparture)
        if (request.Date.HasValue)
        {
            var day   = request.Date.Value.ToDateTime(TimeOnly.MinValue);
            var dayEnd = day.AddDays(1);
            query = query.Where(t => t.ScheduledDeparture >= day && t.ScheduledDeparture < dayEnd);
        }

        // Filter by status
        if (!string.IsNullOrWhiteSpace(request.Status) &&
            Enum.TryParse<TripStatus>(request.Status, ignoreCase: true, out var status))
        {
            query = query.Where(t => t.Status == status);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var trips = await query
            .OrderByDescending(t => t.ScheduledDeparture)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(t => new TripDto(
                t.Id,
                t.BusId,
                t.Bus.PlateNumber,
                t.Route != null ? t.Route.Name : null,
                t.Type.ToString(),
                t.ScheduledDeparture,
                t.ActualDeparture,
                t.ActualArrival,
                t.Status.ToString(),
                t.RepeatDays,
                t.Bus.Driver != null ? t.Bus.Driver.FullName : null,
                t.Bus.AssistantDriver != null ? t.Bus.AssistantDriver.FullName : null))
            .ToListAsync(cancellationToken);

        return PagedResult<TripDto>.Create(trips, totalCount, request.PageNumber, request.PageSize);
    }
}
