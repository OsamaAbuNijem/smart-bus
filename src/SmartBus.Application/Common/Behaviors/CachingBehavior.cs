using MediatR;
using Microsoft.Extensions.Logging;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Interfaces;

namespace SmartBus.Application.Common.Behaviors;

/// <summary>
/// Cache-aside MediatR behavior. Any request that implements <see cref="ICacheableQuery"/>
/// goes through Redis first; on miss, calls the handler and caches the result.
/// </summary>
public class CachingBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly ICacheService _cache;
    private readonly ILogger<CachingBehavior<TRequest, TResponse>> _logger;

    public CachingBehavior(ICacheService cache, ILogger<CachingBehavior<TRequest, TResponse>> logger)
    { _cache = cache; _logger = logger; }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        if (request is not ICacheableQuery cacheable) return await next();

        var key = cacheable.CacheKey;
        var cached = await _cache.GetAsync<TResponse>(key, ct);
        if (cached is not null)
        {
            _logger.LogDebug("Cache HIT: {Key}", key);
            return cached;
        }

        _logger.LogDebug("Cache MISS: {Key}", key);
        var response = await next();
        if (response is not null)
            await _cache.SetAsync(key, response, cacheable.CacheExpiry ?? TimeSpan.FromMinutes(2), ct);
        return response;
    }
}
