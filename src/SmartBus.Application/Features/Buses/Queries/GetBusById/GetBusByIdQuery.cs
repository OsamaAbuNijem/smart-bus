using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Buses.Queries.GetAllBuses;

namespace SmartBus.Application.Features.Buses.Queries.GetBusById;

public record GetBusByIdQuery(Guid BusId) : IRequest<Result<BusDto>>, ICacheableQuery
{
    public string CacheKey => $"bus:{BusId}";
    public TimeSpan? CacheExpiry => TimeSpan.FromMinutes(5);
}
