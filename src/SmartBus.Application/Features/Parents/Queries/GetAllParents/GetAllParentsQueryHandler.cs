using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Parents.Queries.GetAllParents;

public class GetAllParentsQueryHandler : IRequestHandler<GetAllParentsQuery, PagedResult<ParentDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllParentsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<ParentDto>> Handle(GetAllParentsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Parents.Where(p => !p.IsDeleted).Include(p => p.Children);
        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderBy(p => p.FullName)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(p => new ParentDto(p.Id, p.FullName, p.PhoneNumber, p.Children.Count(c => !c.IsDeleted), p.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<ParentDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
