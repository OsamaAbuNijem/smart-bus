using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Schools.Queries.GetMyFleetSchoolInfo;

public class GetMyFleetSchoolInfoQueryHandler
    : IRequestHandler<GetMyFleetSchoolInfoQuery, Result<SchoolInfoDto?>>
{
    private readonly IApplicationDbContext _context;

    public GetMyFleetSchoolInfoQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<SchoolInfoDto?>> Handle(
        GetMyFleetSchoolInfoQuery request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(request.UserId))
            return Result<SchoolInfoDto?>.Success(null);

        // Resolve the driver / assistant row → SchoolId → School. Same
        // shape as GetMyFleetSchoolQuery but joins School in so we can
        // return name + city + phone in one round trip.
        var basics = await _context.Drivers
            .Where(d => !d.IsDeleted
                     && d.UserId == request.UserId
                     && d.SchoolId != null)
            .Join(_context.Schools.Where(s => !s.IsDeleted),
                d => d.SchoolId, s => s.Id,
                (d, s) => new
                {
                    s.Id,
                    s.Name,
                    s.City,
                    s.PhoneNumber,
                })
            .FirstOrDefaultAsync(cancellationToken);
        if (basics is null)
            return Result<SchoolInfoDto?>.Success(null);

        // Pull the currently-active subscription so we can surface its
        // SuperAdmin-managed feature flags to the app. No active sub →
        // default both flags to true (matches the column default; it's
        // also the safest fallback when subscription state is missing).
        var now = DateTime.UtcNow;
        var flags = await _context.Subscriptions
            .Where(s => s.SchoolId == basics.Id
                     && !s.IsDeleted
                     && s.IsActive
                     && s.ActivationDate <= now
                     && s.ExpirationDate >= now)
            .Select(s => new { s.EnableQr, s.EnableNfc })
            .FirstOrDefaultAsync(cancellationToken);

        return Result<SchoolInfoDto?>.Success(new SchoolInfoDto(
            basics.Name,
            basics.City,
            basics.PhoneNumber,
            EnableQr:  flags?.EnableQr  ?? true,
            EnableNfc: flags?.EnableNfc ?? true));
    }
}
