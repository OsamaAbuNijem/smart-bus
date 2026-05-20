using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Application.Features.Schools.Queries.GetMyFleetSchool;

public class GetMyFleetSchoolQueryHandler : IRequestHandler<GetMyFleetSchoolQuery, Guid?>
{
    private readonly IApplicationDbContext _context;

    public GetMyFleetSchoolQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Guid?> Handle(GetMyFleetSchoolQuery request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(request.UserId)) return null;

        // Drivers and Assistants both live in the Drivers table; DriverType
        // disambiguates. The lookup here doesn't care about the role.
        return await _context.Drivers
            .Where(d => !d.IsDeleted && d.UserId == request.UserId && d.SchoolId != null)
            .Select(d => d.SchoolId)
            .FirstOrDefaultAsync(cancellationToken);
    }
}
