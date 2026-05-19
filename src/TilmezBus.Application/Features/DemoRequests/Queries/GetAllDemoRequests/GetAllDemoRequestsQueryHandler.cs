using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.DemoRequests.Queries.GetAllDemoRequests;

public class GetAllDemoRequestsQueryHandler
    : IRequestHandler<GetAllDemoRequestsQuery, PagedResult<DemoRequestDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllDemoRequestsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<DemoRequestDto>> Handle(GetAllDemoRequestsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.DemoRequests.AsQueryable();
        if (request.Status.HasValue)
            query = query.Where(d => d.Status == request.Status.Value);

        var total = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(d => d.CreatedAt)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(d => new DemoRequestDto(
                d.Id,
                d.SchoolName,
                d.ContactName,
                d.Email,
                d.PhoneNumber,
                d.Notes,
                d.Status,
                d.CreatedAt,
                d.CompletedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<DemoRequestDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
