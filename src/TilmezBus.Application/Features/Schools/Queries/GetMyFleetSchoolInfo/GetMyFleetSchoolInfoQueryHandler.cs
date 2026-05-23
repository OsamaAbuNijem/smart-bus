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
        var info = await _context.Drivers
            .Where(d => !d.IsDeleted
                     && d.UserId == request.UserId
                     && d.SchoolId != null)
            .Join(_context.Schools.Where(s => !s.IsDeleted),
                d => d.SchoolId, s => s.Id,
                (d, s) => new SchoolInfoDto(s.Name, s.City, s.PhoneNumber))
            .FirstOrDefaultAsync(cancellationToken);

        return Result<SchoolInfoDto?>.Success(info);
    }
}
