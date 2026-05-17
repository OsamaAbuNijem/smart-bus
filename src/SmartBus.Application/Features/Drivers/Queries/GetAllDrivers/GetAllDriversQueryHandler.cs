using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;

public class GetAllDriversQueryHandler : IRequestHandler<GetAllDriversQuery, PagedResult<DriverDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllDriversQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<DriverDto>> Handle(GetAllDriversQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Drivers.Where(d => !d.IsDeleted);

        if (request.SchoolId.HasValue)
            query = query.Where(d => d.SchoolId == request.SchoolId.Value);

        if (request.DriverType.HasValue)
            query = query.Where(d => d.DriverType == request.DriverType.Value);

        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderBy(d => d.FullName)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(d => new DriverDto(
                d.Id, d.FullName, d.FullNameEn,
                d.PhoneNumber,
                d.IsActive, d.DriverType, d.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<DriverDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
