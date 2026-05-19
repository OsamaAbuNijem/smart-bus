using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Routes.Queries.GetRouteById;

public class GetRouteByIdQueryHandler : IRequestHandler<GetRouteByIdQuery, Result<RouteDetailDto>>
{
    private readonly IApplicationDbContext _context;

    public GetRouteByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<RouteDetailDto>> Handle(GetRouteByIdQuery request, CancellationToken cancellationToken)
    {
        var route = await _context.Routes
            .Where(r => r.Id == request.RouteId && !r.IsDeleted)
            .Include(r => r.Stops.OrderBy(s => s.Order))
            .FirstOrDefaultAsync(cancellationToken);

        if (route is null) return Result<RouteDetailDto>.Failure("Route not found.");

        var dto = new RouteDetailDto(
            route.Id, route.Name, route.Description,
            route.StartLatitude, route.StartLongitude,
            route.EndLatitude, route.EndLongitude,
            route.Stops.Select(s => new StopDto(s.Id, s.Name, s.Latitude, s.Longitude, s.Order)).ToList(),
            route.CreatedAt);

        return Result<RouteDetailDto>.Success(dto);
    }
}
