using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Drivers.Queries.GetAllDrivers;

namespace TilmezBus.Application.Features.Drivers.Queries.GetDriverById;

public record GetDriverByIdQuery(Guid DriverId) : IRequest<Result<DriverDto>>, ICacheableQuery
{
    public string CacheKey => $"driver:{DriverId}";
    public TimeSpan? CacheExpiry => TimeSpan.FromMinutes(5);
}
