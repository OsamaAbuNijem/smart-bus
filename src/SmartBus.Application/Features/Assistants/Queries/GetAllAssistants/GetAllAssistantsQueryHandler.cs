using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Assistants.Queries.GetAllAssistants;

public class GetAllAssistantsQueryHandler : IRequestHandler<GetAllAssistantsQuery, PagedResult<AssistantDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllAssistantsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<AssistantDto>> Handle(GetAllAssistantsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Assistants.Where(a => !a.IsDeleted);
        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderBy(a => a.FullName)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(a => new AssistantDto(a.Id, a.FullName, a.PhoneNumber, a.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<AssistantDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
