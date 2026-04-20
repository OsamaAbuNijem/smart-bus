namespace SmartBus.Application.Common.Caching;

/// <summary>Opt-in marker for MediatR queries that should go through the Redis cache.</summary>
public interface ICacheableQuery
{
    /// <summary>Fully qualified cache key for this query instance (include all filters).</summary>
    string CacheKey { get; }
    /// <summary>Optional TTL override. Defaults to 2 minutes when null.</summary>
    TimeSpan? CacheExpiry => null;
}

/// <summary>Opt-in marker for MediatR commands that should evict cache entries after success.</summary>
public interface ICacheInvalidator
{
    /// <summary>Exact keys to remove (e.g. "bus:123").</summary>
    IEnumerable<string> CacheKeysToInvalidate => Array.Empty<string>();
    /// <summary>Wildcard patterns to remove (e.g. "buses:page:*").</summary>
    IEnumerable<string> CachePatternsToInvalidate => Array.Empty<string>();
}
