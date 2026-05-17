using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;

namespace SmartBus.Application.Features.Schools.Queries.GetMyFleetSchool;

public class GetMyFleetSchoolQueryHandler : IRequestHandler<GetMyFleetSchoolQuery, Guid?>
{
    private readonly IApplicationDbContext _context;

    public GetMyFleetSchoolQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Guid?> Handle(GetMyFleetSchoolQuery request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(request.UserId)) return null;

        // Driver/Assistant rows may live in either table depending on which
        // path created them (admin form vs. QR registration). Check both.
        var driverSchool = await _context.Drivers
            .Where(d => !d.IsDeleted && d.UserId == request.UserId && d.SchoolId != null)
            .Select(d => d.SchoolId)
            .FirstOrDefaultAsync(cancellationToken);
        if (driverSchool is not null) return driverSchool;

        var assistantSchool = await _context.Assistants
            .Where(a => !a.IsDeleted && a.UserId == request.UserId && a.SchoolId != null)
            .Select(a => a.SchoolId)
            .FirstOrDefaultAsync(cancellationToken);
        return assistantSchool;
    }
}
