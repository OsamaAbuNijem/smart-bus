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
        IQueryable<SmartBus.Domain.Entities.Student> query = _context.Students
            .Where(s => !s.IsDeleted)
            .Include(s => s.Route);

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
                s.Id, s.FullName, s.FullNameEn, s.Grade, s.Class,
                s.ParentName, s.ParentNameEn, s.ParentPhone,
                s.Route != null ? s.Route.Name : null,
                s.Latitude, s.Longitude, s.HomeArea, s.HomeStreet, s.HomeBuildingNumber,
                s.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<StudentDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
