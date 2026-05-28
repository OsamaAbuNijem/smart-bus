using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Infrastructure.Services;

/// <summary>
/// Delivers and verifies OTPs via Prelude (api.prelude.dev/v2). Prelude
/// owns code generation, channel selection, expiry, and attempt
/// counting — we just trigger a verification and later ask whether a
/// user-typed code was approved.
///
/// API auth is Bearer key; requests are JSON.
/// </summary>
public sealed class PreludeOtpSender : IOtpSender
{
    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
    };

    private readonly HttpClient _http;
    private readonly ILogger<PreludeOtpSender> _logger;

    public PreludeOtpSender(
        HttpClient http,
        IConfiguration config,
        ILogger<PreludeOtpSender> logger)
    {
        _http   = http;
        _logger = logger;

        var apiKey = config["Prelude:ApiKey"]
            ?? throw new InvalidOperationException("Prelude:ApiKey is not configured.");
        _http.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", apiKey);
        if (_http.BaseAddress is null)
            _http.BaseAddress = new Uri("https://api.prelude.dev/");
    }

    public async Task SendAsync(string phoneNumber, CancellationToken ct = default)
    {
        var payload = new
        {
            target = new { type = "phone_number", value = phoneNumber },
        };
        using var resp = await _http.PostAsJsonAsync("v2/verification", payload, JsonOpts, ct);
        var body = await resp.Content.ReadAsStringAsync(ct);
        if (!resp.IsSuccessStatusCode)
        {
            _logger.LogWarning(
                "Prelude verification create failed for {Phone}. status={Status} body={Body}",
                phoneNumber, resp.StatusCode, body);
            throw new InvalidOperationException(
                $"Prelude verification create failed: {resp.StatusCode}.");
        }
        // A 2xx response is not enough — Prelude returns status="retry"
        // or "blocked" with HTTP 200 when its fraud guard / rate limit
        // refuses to actually deliver. Only "success" means an OTP is
        // being sent.
        string? status = null;
        try
        {
            using var doc = JsonDocument.Parse(body);
            if (doc.RootElement.TryGetProperty("status", out var s)) status = s.GetString();
        }
        catch (JsonException) { /* fall through to status-check below */ }

        if (status == "success")
        {
            _logger.LogInformation("Prelude verification created for {Phone}.", phoneNumber);
            return;
        }
        _logger.LogWarning(
            "Prelude refused to deliver for {Phone}: status={PreludeStatus} body={Body}",
            phoneNumber, status, body);
        throw new InvalidOperationException(
            $"Prelude verification not sent: status='{status ?? "unknown"}'.");
    }

    public async Task<bool> VerifyAsync(string phoneNumber, string code, CancellationToken ct = default)
    {
        var payload = new
        {
            target = new { type = "phone_number", value = phoneNumber },
            code   = code,
        };
        using var resp = await _http.PostAsJsonAsync("v2/verification/check", payload, JsonOpts, ct);
        var body = await resp.Content.ReadAsStringAsync(ct);
        if (!resp.IsSuccessStatusCode)
        {
            _logger.LogInformation(
                "Prelude verification check non-success for {Phone}: status={Status} body={Body}",
                phoneNumber, resp.StatusCode, body);
            return false;
        }
        try
        {
            using var doc = JsonDocument.Parse(body);
            // Prelude returns status="success" on a correct code; everything
            // else (failure, expired_or_not_found, retry, blocked) is a no.
            return doc.RootElement.TryGetProperty("status", out var s)
                && s.GetString() == "success";
        }
        catch (JsonException)
        {
            _logger.LogWarning("Prelude check returned non-JSON body: {Body}", body);
            return false;
        }
    }
}
