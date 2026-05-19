using Microsoft.Extensions.Diagnostics.HealthChecks;
using StackExchange.Redis;

namespace TilmezBus.API.HealthChecks;

/// <summary>Pings Redis via the shared multiplexer. Degraded (not unhealthy) if disconnected
/// — the app works without Redis via the cache-service's graceful fallback.</summary>
public class RedisHealthCheck : IHealthCheck
{
    private readonly IConnectionMultiplexer _redis;
    public RedisHealthCheck(IConnectionMultiplexer redis) => _redis = redis;

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            if (!_redis.IsConnected) return HealthCheckResult.Degraded("Redis multiplexer not connected");
            var pong = await _redis.GetDatabase().PingAsync();
            return HealthCheckResult.Healthy($"Redis responded in {pong.TotalMilliseconds:F0}ms");
        }
        catch (Exception ex) { return HealthCheckResult.Degraded("Redis ping failed", ex); }
    }
}
