using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Queries.GetAllStudents;

public class GetAllStudentsQueryHandler : IRequestHandler<GetAllStudentsQuery, PagedResult<StudentDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllStudentsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<StudentDto>> Handle(GetAllStudentsQuery request, CancellationToken cancellationToken)
    {
        // School scope is required for tenant isolation. SuperAdmin call sites
        // that legitimately need cross-school data should use a different
        // dedicated query rather than passing null here.
        if (!request.SchoolId.HasValue)
            return PagedResult<StudentDto>.Create(Array.Empty<StudentDto>(), 0, request.PageNumber, request.PageSize);

        // Filter to the school's currently-active subscription. Once that
        // subscription expires (or IsActive is cleared), the admin sees an
        // empty grid — by design.
        var schoolIdString = request.SchoolId.Value.ToString();
        var now = DateTime.UtcNow;
        var activeStudentIds = _context.SubscriptionStudents
            .Where(x => x.Subscription!.SchoolId == request.SchoolId.Value
                     && x.Subscription.IsActive
                     && x.Subscription.ActivationDate <= now
                     && x.Subscription.ExpirationDate >= now
                     && !x.Subscription.IsDeleted
                     && !x.Student!.IsDeleted)
            .Select(x => x.StudentId);

        IQueryable<TilmezBus.Domain.Entities.Student> query = _context.Students
            .Where(s => !s.IsDeleted && s.SchoolId == schoolIdString)
            .Where(s => activeStudentIds.Contains(s.Id))
            .Include(s => s.Parent);

        // RouteId filter accepted but is a no-op now that Routes are gone —
        // kept on the query DTO for binary compat with older admin clients.

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var term = request.Name.Trim();
            var lang = request.Lang?.Trim().ToLowerInvariant();
            // Locale-scoped search: English UI searches only FullNameEn,
            // Arabic UI searches only FullName. When Lang is null (legacy
            // admin grid) we keep the original "either field" behavior.
            // Lowercase both sides so the match is case-insensitive — EF
            // translates ToLower() to SQL LOWER(); harmless on Arabic where
            // case doesn't apply.
            var termLower = term.ToLowerInvariant();
            query = lang switch
            {
                "en" => query.Where(s =>
                    s.FullNameEn != null &&
                    s.FullNameEn.ToLower().Contains(termLower)),
                "ar" => query.Where(s =>
                    s.FullName.ToLower().Contains(termLower)),
                _    => query.Where(s =>
                    s.FullName.ToLower().Contains(termLower) ||
                    (s.FullNameEn != null && s.FullNameEn.ToLower().Contains(termLower))),
            };
        }

        if (!string.IsNullOrWhiteSpace(request.Grade))
            query = query.Where(s => s.Grade == request.Grade);

        if (!string.IsNullOrWhiteSpace(request.HomeArea))
        {
            var area = request.HomeArea.Trim();
            query = query.Where(s => s.HomeArea != null && EF.Functions.Like(s.HomeArea, $"%{area}%"));
        }

        var total = await query.CountAsync(cancellationToken);
        var orderLang = request.Lang?.Trim().ToLowerInvariant();
        var ordered = orderLang == "en"
            // FullNameEn is nullable — fall back to FullName so rows without
            // an English name still appear in a deterministic spot.
            ? query.OrderBy(s => s.FullNameEn ?? s.FullName)
            : query.OrderBy(s => s.FullName);
        var items = await ordered
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(s => new StudentDto(
                s.Id, s.FullName, s.FullNameEn, s.NationalNumber, s.Grade, s.Class,
                s.Parent != null ? s.Parent.FullName    : string.Empty,
                s.Parent != null ? s.Parent.PhoneNumber : string.Empty,
                null,
                s.Latitude, s.Longitude, s.HomeArea, s.HomeStreet, s.HomeBuildingNumber,
                s.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<StudentDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
