using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Infrastructure.Services;

/// <summary>
/// Delivers and verifies OTPs via Twilio Verify v2. Twilio owns code
/// generation, expiry, and attempt counting — we just kick off a
/// verification and later ask whether a user-typed code was approved.
///
/// WhatsApp is tried first; on send failure we fall back to SMS so the
/// user still gets a code if WhatsApp isn't available on their number.
/// </summary>
public sealed class TwilioVerifyOtpSender : IOtpSender
{
    private readonly HttpClient _http;
    private readonly ILogger<TwilioVerifyOtpSender> _logger;
    private readonly string _verifySid;

    public TwilioVerifyOtpSender(
        HttpClient http,
        IConfiguration config,
        ILogger<TwilioVerifyOtpSender> logger)
    {
        _http   = http;
        _logger = logger;

        var accountSid = config["Twilio:AccountSid"]
            ?? throw new InvalidOperationException("Twilio:AccountSid is not configured.");
        var authToken = config["Twilio:AuthToken"]
            ?? throw new InvalidOperationException("Twilio:AuthToken is not configured.");
        _verifySid = config["Twilio:VerifySid"]
            ?? throw new InvalidOperationException("Twilio:VerifySid is not configured (VA…).");

        var creds = Convert.ToBase64String(
            Encoding.ASCII.GetBytes($"{accountSid}:{authToken}"));
        _http.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Basic", creds);
        if (_http.BaseAddress is null)
            _http.BaseAddress = new Uri("https://verify.twilio.com/");
    }

    public async Task SendAsync(string phoneNumber, CancellationToken ct = default)
    {
        // SMS first — the WhatsApp channel needs a per-Verify-Service
        // configuration with an approved WhatsApp sender, which we don't
        // yet have. Without it Twilio silently substitutes SMS anyway.
        // Flip the order back once the WhatsApp sender is provisioned.
        if (await TryCreateVerification(phoneNumber, "sms", ct)) return;
        if (await TryCreateVerification(phoneNumber, "whatsapp", ct)) return;
        throw new InvalidOperationException(
            $"Twilio Verify create failed on both SMS and WhatsApp for {phoneNumber}.");
    }

    public async Task<bool> VerifyAsync(string phoneNumber, string code, CancellationToken ct = default)
    {
        var url = $"v2/Services/{_verifySid}/VerificationCheck";
        var form = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["To"]   = phoneNumber,
            ["Code"] = code,
        });

        using var resp = await _http.PostAsync(url, form, ct);
        var body = await resp.Content.ReadAsStringAsync(ct);
        if (!resp.IsSuccessStatusCode)
        {
            // 404 = no pending verification (expired / never requested);
            // any other 4xx/5xx we treat as not approved and log.
            _logger.LogInformation(
                "Twilio Verify check non-success for {Phone}: status={Status} body={Body}",
                phoneNumber, resp.StatusCode, body);
            return false;
        }
        try
        {
            using var doc = JsonDocument.Parse(body);
            return doc.RootElement.TryGetProperty("status", out var s)
                && s.GetString() == "approved";
        }
        catch (JsonException)
        {
            _logger.LogWarning("Twilio Verify check returned non-JSON body: {Body}", body);
            return false;
        }
    }

    private async Task<bool> TryCreateVerification(string phoneNumber, string channel, CancellationToken ct)
    {
        var url = $"v2/Services/{_verifySid}/Verifications";
        var form = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["To"]      = phoneNumber,
            ["Channel"] = channel,
        });

        using var resp = await _http.PostAsync(url, form, ct);
        var body = await resp.Content.ReadAsStringAsync(ct);
        if (resp.IsSuccessStatusCode)
        {
            _logger.LogInformation(
                "Twilio Verify created via {Channel} for {Phone}.", channel, phoneNumber);
            return true;
        }
        _logger.LogWarning(
            "Twilio Verify create failed via {Channel} for {Phone}. status={Status} body={Body}",
            channel, phoneNumber, resp.StatusCode, body);
        return false;
    }
}
