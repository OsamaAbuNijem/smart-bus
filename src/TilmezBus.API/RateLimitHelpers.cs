using System.Text.Json;

namespace TilmezBus.API;

/// <summary>
/// Small helpers used by the rate-limit policies. The auth bucket partitions
/// by <c>(IP, email)</c> so two users on the same machine don't share a
/// quota, while brute-force loops on a single email still get capped.
/// </summary>
public static class RateLimitHelpers
{
    /// <summary>
    /// Peek the <c>email</c> field out of an unread JSON request body without
    /// consuming the stream. Returns the lower-cased email when present, or
    /// <c>null</c> if the body isn't JSON, doesn't have an <c>email</c>
    /// property, or can't be read for any reason — callers should treat null
    /// as "fall back to IP-only partitioning".
    /// </summary>
    public static string? PeekLoginEmail(HttpContext ctx)
    {
        // Only JSON POSTs to the login endpoints are interesting. Anything
        // else (GETs, other content-types) returns null and the partition
        // key falls back to the IP-only path.
        if (!HttpMethods.IsPost(ctx.Request.Method)) return null;
        var contentType = ctx.Request.ContentType ?? string.Empty;
        if (!contentType.Contains("application/json", StringComparison.OrdinalIgnoreCase)) return null;

        try
        {
            // EnableBuffering makes the request stream replayable so MVC can
            // still bind the body downstream after we peek at it.
            ctx.Request.EnableBuffering();
            ctx.Request.Body.Position = 0;
            using var reader = new StreamReader(ctx.Request.Body,
                System.Text.Encoding.UTF8, detectEncodingFromByteOrderMarks: false,
                bufferSize: 1024, leaveOpen: true);
            var body = reader.ReadToEndAsync().GetAwaiter().GetResult();
            ctx.Request.Body.Position = 0;
            if (string.IsNullOrWhiteSpace(body)) return null;

            using var doc = JsonDocument.Parse(body);
            if (doc.RootElement.ValueKind != JsonValueKind.Object) return null;
            foreach (var prop in doc.RootElement.EnumerateObject())
            {
                if (string.Equals(prop.Name, "email", StringComparison.OrdinalIgnoreCase)
                    && prop.Value.ValueKind == JsonValueKind.String)
                {
                    return prop.Value.GetString()?.Trim().ToLowerInvariant();
                }
            }
            return null;
        }
        catch
        {
            return null;
        }
    }
}
