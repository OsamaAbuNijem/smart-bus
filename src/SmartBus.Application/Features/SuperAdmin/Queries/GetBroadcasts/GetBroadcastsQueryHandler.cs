using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;

namespace SmartBus.Application.Features.SuperAdmin.Queries.GetBroadcasts;

public class GetBroadcastsQueryHandler
    : IRequestHandler<GetBroadcastsQuery, IReadOnlyList<BroadcastDto>>
{
    private readonly IApplicationDbContext _context;

    public GetBroadcastsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<IReadOnlyList<BroadcastDto>> Handle(GetBroadcastsQuery request, CancellationToken cancellationToken)
    {
        var limit = request.Limit <= 0 ? 50 : Math.Min(request.Limit, 200);
        return await _context.SuperAdminBroadcasts
            .Where(b => !b.IsDeleted)
            .OrderByDescending(b => b.CreatedAt)
            .Take(limit)
            .Select(b => new BroadcastDto(
                b.Id, b.Title, b.Message, b.Target, b.SchoolIdsCsv,
                b.Recipients, b.Delivered, b.CreatedAt))
            .ToListAsync(cancellationToken);
    }
}
