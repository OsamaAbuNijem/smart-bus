using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Alerts.Queries.GetAllAlerts;

public class GetAllAlertsQueryHandler : IRequestHandler<GetAllAlertsQuery, PagedResult<AlertDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllAlertsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<AlertDto>> Handle(GetAllAlertsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Alerts.Where(a => !a.IsDeleted);
        if (request.Status.HasValue) query = query.Where(a => a.Status == request.Status.Value);
        if (request.Severity.HasValue) query = query.Where(a => a.Severity == request.Severity.Value);

        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderByDescending(a => a.CreatedAt)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(a => new AlertDto(a.Id, a.Title, a.Message, a.Severity, a.Status, a.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<AlertDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
