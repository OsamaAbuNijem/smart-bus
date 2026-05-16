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
        var now = DateTime.UtcNow;
        var items = await query
            .OrderBy(s => s.Name)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(s => new
            {
                School = s,
                // Pick the school's currently-active subscription (if multiple
                // sneak through, take the most-recently-activated). Translated
                // to a LATERAL/CROSS-APPLY subquery by the EF Core PG provider.
                ActiveSub = _context.Subscriptions
                    .Where(sub => sub.SchoolId == s.Id
                               && !sub.IsDeleted
                               && sub.IsActive
                               && sub.ActivationDate <= now
                               && sub.ExpirationDate >= now)
                    .OrderByDescending(sub => sub.ActivationDate)
                    .Select(sub => new { sub.ActivationDate, sub.SubscriptionType })
                    .FirstOrDefault()
            })
            .Select(x => new SchoolDto(
                x.School.Id, x.School.Name, x.School.City, x.School.ContactEmail,
                x.School.PhoneNumber, x.School.AdminEmail, x.School.Notes, x.School.CreatedAt,
                x.ActiveSub != null ? (DateTime?)x.ActiveSub.ActivationDate : null,
                x.ActiveSub != null ? (SmartBus.Domain.Enums.SubscriptionType?)x.ActiveSub.SubscriptionType : null))
            .ToListAsync(cancellationToken);

        return PagedResult<SchoolDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
