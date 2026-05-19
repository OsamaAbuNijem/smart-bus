using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Drivers.Queries.GetAllDrivers;

namespace TilmezBus.Application.Features.Drivers.Queries.GetDriverById;

public class GetDriverByIdQueryHandler : IRequestHandler<GetDriverByIdQuery, Result<DriverDto>>
{
    private readonly IApplicationDbContext _context;

    public GetDriverByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<DriverDto>> Handle(GetDriverByIdQuery request, CancellationToken cancellationToken)
    {
        var driver = await _context.Drivers
            .Where(d => d.Id == request.DriverId && !d.IsDeleted)
            .Select(d => new DriverDto(d.Id, d.FullName, d.FullNameEn, d.PhoneNumber, d.IsActive, d.DriverType, d.CreatedAt))
            .FirstOrDefaultAsync(cancellationToken);

        return driver is null
            ? Result<DriverDto>.Failure($"Driver '{request.DriverId}' not found.")
            : Result<DriverDto>.Success(driver);
    }
}
