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
        var now = DateTime.UtcNow;

        // Step 1: text/city filters apply directly to the School table — they
        // don't need the subscription join, so we narrow early to keep the
        // LATERAL subquery cheap.
        var schools = _context.Schools.Where(s => !s.IsDeleted);
        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            // Case-insensitive substring match. ToLower().Contains() keeps
            // the predicate provider-agnostic; the PG provider translates it
            // to LOWER() + LIKE which uses the existing index where possible.
            var name = request.Name.Trim().ToLower();
            schools = schools.Where(s => s.Name.ToLower().Contains(name));
        }
        if (!string.IsNullOrWhiteSpace(request.City))
            schools = schools.Where(s => s.City == request.City.Trim());

        // Step 2: project each school with its newest-activation subscription
        // (regardless of state). The provider turns this into a LATERAL join.
        var withSub = schools.Select(s => new
        {
            School = s,
            LastSub = _context.Subscriptions
                .Where(sub => sub.SchoolId == s.Id && !sub.IsDeleted)
                .OrderByDescending(sub => sub.ActivationDate)
                .Select(sub => new
                {
                    sub.SubscriptionType,
                    sub.ActivationDate,
                    sub.ExpirationDate,
                    sub.IsActive
                })
                .FirstOrDefault()
        });

        // Step 3: plan + status filters compare against the LastSub row.
        if (request.Plan is not null)
            withSub = withSub.Where(x => x.LastSub != null && x.LastSub.SubscriptionType == request.Plan);

        if (request.Status is not null)
        {
            // Active = last sub IsActive AND today ∈ [activation, expiration].
            // Inactive = the school has no sub, or the sub is disabled, or
            // today falls outside the [activation, expiration] window.
            withSub = request.Status switch
            {
                SchoolStatusFilter.Active   => withSub.Where(x => x.LastSub != null
                                                                  && x.LastSub.IsActive
                                                                  && x.LastSub.ActivationDate <= now
                                                                  && x.LastSub.ExpirationDate >= now),
                SchoolStatusFilter.Inactive => withSub.Where(x => x.LastSub == null
                                                                  || !x.LastSub.IsActive
                                                                  || x.LastSub.ActivationDate > now
                                                                  || x.LastSub.ExpirationDate < now),
                _ => withSub
            };
        }

        var total = await withSub.CountAsync(cancellationToken);
        var items = await withSub
            .OrderBy(x => x.School.Name)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(x => new SchoolDto(
                x.School.Id, x.School.Name, x.School.City,
                x.School.PhoneNumber, x.School.AdminEmail, x.School.ContactName,
                x.School.Latitude, x.School.Longitude, x.School.LogoUrl,
                x.School.CreatedAt,
                x.LastSub != null ? (DateTime?)x.LastSub.ActivationDate : null,
                x.LastSub != null ? (DateTime?)x.LastSub.ExpirationDate : null,
                x.LastSub != null ? (SmartBus.Domain.Enums.SubscriptionType?)x.LastSub.SubscriptionType : null,
                x.LastSub != null ? (bool?)x.LastSub.IsActive : null,
                (int?)null, (int?)null, (decimal?)null))
            .ToListAsync(cancellationToken);

        return PagedResult<SchoolDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
