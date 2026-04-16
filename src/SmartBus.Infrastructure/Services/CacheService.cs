using System.Text.Json;
using Microsoft.Extensions.Logging;
using SmartBus.Application.Common.Interfaces;
using StackExchange.Redis;

namespace SmartBus.Infrastructure.Services;

public class CacheService : ICacheService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly ILogger<CacheService> _logger;

    public CacheService(IConnectionMultiplexer redis, ILogger<CacheService> logger)
    {
        _redis = redis;
        _logger = logger;
    }

    private IDatabase? GetDb()
    {
        try
        {
            if (!_redis.IsConnected) return null;
            return _redis.GetDatabase();
        }
        catch { return null; }
    }

    public async Task<T?> GetAsync<T>(string key, CancellationToken cancellationToken = default)
    {
        try
        {
            var db = GetDb();
            if (db is null) return default;
            var value = await db.StringGetAsync(key);
            return value.IsNullOrEmpty ? default : JsonSerializer.Deserialize<T>(value!);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Cache GET failed for key: {Key}", key);
            return default;
        }
    }

    public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null, CancellationToken cancellationToken = default)
    {
        try
        {
            var db = GetDb();
            if (db is null) return;
            var json = JsonSerializer.Serialize(value);
            await db.StringSetAsync(key, json, expiry ?? TimeSpan.FromMinutes(10));
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Cache SET failed for key: {Key}", key);
        }
    }

    public async Task RemoveAsync(string key, CancellationToken cancellationToken = default)
    {
        try
        {
            var db = GetDb();
            if (db is null) return;
            await db.KeyDeleteAsync(key);
        }
        catch (Exception ex) { _logger.LogWarning(ex, "Cache DELETE failed for key: {Key}", key); }
    }

    public async Task<bool> ExistsAsync(string key, CancellationToken cancellationToken = default)
    {
        try
        {
            var db = GetDb();
            if (db is null) return false;
            return await db.KeyExistsAsync(key);
        }
        catch { return false; }
    }

    public async Task RemoveByPatternAsync(string pattern, CancellationToken cancellationToken = default)
    {
        try
        {
            if (!_redis.IsConnected) return;
            var server = _redis.GetServer(_redis.GetEndPoints().First());
            var keys = server.Keys(pattern: pattern).ToArray();
            var db = GetDb();
            if (db is not null && keys.Length > 0)
                await db.KeyDeleteAsync(keys);
        }
        catch (Exception ex) { _logger.LogWarning(ex, "Cache pattern DELETE failed: {Pattern}", pattern); }
    }
}
