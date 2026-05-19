using MediatR;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Application.Common.Behaviors;

/// <summary>
/// After a command succeeds, evicts cache keys/patterns declared by <see cref="ICacheInvalidator"/>.
/// Runs *after* the handler; invalidation is skipped if the handler threw.
/// </summary>
public class CacheInvalidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly ICacheService _cache;
    private readonly ILogger<CacheInvalidationBehavior<TRequest, TResponse>> _logger;

    public CacheInvalidationBehavior(ICacheService cache, ILogger<CacheInvalidationBehavior<TRequest, TResponse>> logger)
    { _cache = cache; _logger = logger; }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        var response = await next();
        if (request is not ICacheInvalidator invalidator) return response;

        foreach (var key in invalidator.CacheKeysToInvalidate)
        {
            await _cache.RemoveAsync(key, ct);
            _logger.LogDebug("Cache invalidate key: {Key}", key);
        }
        foreach (var pattern in invalidator.CachePatternsToInvalidate)
        {
            await _cache.RemoveByPatternAsync(pattern, ct);
            _logger.LogDebug("Cache invalidate pattern: {Pattern}", pattern);
        }
        return response;
    }
}
