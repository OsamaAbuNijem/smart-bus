using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Queries.GetAllStudents;

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

        IQueryable<SmartBus.Domain.Entities.Student> query = _context.Students
            .Where(s => !s.IsDeleted && s.SchoolId == schoolIdString)
            .Where(s => activeStudentIds.Contains(s.Id))
            .Include(s => s.Route)
            .Include(s => s.Parent);

        if (request.RouteId.HasValue)
            query = query.Where(s => s.RouteId == request.RouteId.Value);

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var term = request.Name.Trim();
            query = query.Where(s =>
                EF.Functions.Like(s.FullName, $"%{term}%") ||
                (s.FullNameEn != null && EF.Functions.Like(s.FullNameEn, $"%{term}%")));
        }

        if (!string.IsNullOrWhiteSpace(request.Grade))
            query = query.Where(s => s.Grade == request.Grade);

        if (!string.IsNullOrWhiteSpace(request.HomeArea))
        {
            var area = request.HomeArea.Trim();
            query = query.Where(s => s.HomeArea != null && EF.Functions.Like(s.HomeArea, $"%{area}%"));
        }

        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderBy(s => s.FullName)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(s => new StudentDto(
                s.Id, s.FullName, s.FullNameEn, s.NationalNumber, s.Grade, s.Class,
                s.Parent != null ? s.Parent.FullName    : string.Empty,
                s.Parent != null ? s.Parent.PhoneNumber : string.Empty,
                s.Route != null ? s.Route.Name : null,
                s.Latitude, s.Longitude, s.HomeArea, s.HomeStreet, s.HomeBuildingNumber,
                s.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<StudentDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
