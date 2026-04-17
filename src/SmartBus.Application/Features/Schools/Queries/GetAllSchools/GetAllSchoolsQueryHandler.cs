using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Schools.Queries.GetAllSchools;

public class GetAllSchoolsQueryHandler : IRequestHandler<GetAllSchoolsQuery, PagedResult<SchoolDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllSchoolsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<SchoolDto>> Handle(GetAllSchoolsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Schools.Where(s => !s.IsDeleted);
        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderBy(s => s.Name)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(s => new SchoolDto(s.Id, s.Name, s.City, s.ContactEmail, s.PhoneNumber,
                s.AdminEmail, s.Plan, s.MaxBuses, s.IsActive, s.Notes, s.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<SchoolDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
