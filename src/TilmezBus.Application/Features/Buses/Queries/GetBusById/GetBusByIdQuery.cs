using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Buses.Queries.GetAllBuses;

namespace TilmezBus.Application.Features.Buses.Queries.GetBusById;

public record GetBusByIdQuery(Guid BusId) : IRequest<Result<BusDto>>, ICacheableQuery
{
    public string CacheKey => $"bus:{BusId}";
    public TimeSpan? CacheExpiry => TimeSpan.FromMinutes(5);
}
