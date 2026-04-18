using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

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
            .Include(t => t.Bus)
            .Include(t => t.Route);

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
                t.RepeatDays))
            .ToListAsync(cancellationToken);

        return PagedResult<TripDto>.Create(trips, totalCount, request.PageNumber, request.PageSize);
    }
}
