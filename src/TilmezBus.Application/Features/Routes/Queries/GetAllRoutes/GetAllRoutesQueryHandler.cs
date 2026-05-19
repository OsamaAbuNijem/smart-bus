using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Routes.Queries.GetAllRoutes;

public class GetAllRoutesQueryHandler : IRequestHandler<GetAllRoutesQuery, PagedResult<RouteDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllRoutesQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<RouteDto>> Handle(GetAllRoutesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Routes.Where(r => !r.IsDeleted).Include(r => r.Stops);
        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderBy(r => r.Name)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(r => new RouteDto(r.Id, r.Name, r.Description, r.Stops.Count, r.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<RouteDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
