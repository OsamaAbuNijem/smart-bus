using System.Net.Http.Headers;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Infrastructure.Services;

/// <summary>
/// Delivers OTP codes over WhatsApp via Twilio's Messages API. Wired
/// up only when <c>Twilio:AccountSid</c> is configured — otherwise
/// <see cref="DevOtpSender"/> stays in charge so local dev still
/// just logs the code to the console.
///
/// Sandbox (testing): set <c>Twilio:WhatsAppFrom</c> to the Twilio
/// sandbox number (e.g. <c>whatsapp:+14155238886</c>). Each recipient
/// must first opt in by sending the join code to that number from
/// their WhatsApp account.
///
/// Production: swap <c>Twilio:WhatsAppFrom</c> for the approved
/// WhatsApp Sender once Meta business verification lands. The wire
/// format below is identical, only the From line changes.
/// </summary>
public sealed class TwilioWhatsAppOtpSender : IOtpSender
{
    private readonly HttpClient _http;
    private readonly ILogger<TwilioWhatsAppOtpSender> _logger;
    private readonly string _accountSid;
    private readonly string? _from;
    private readonly string? _messagingServiceSid;
    private readonly string? _contentSid;

    public TwilioWhatsAppOtpSender(
        HttpClient http,
        IConfiguration config,
        ILogger<TwilioWhatsAppOtpSender> logger)
    {
        _http   = http;
        _logger = logger;

        _accountSid = config["Twilio:AccountSid"]
            ?? throw new InvalidOperationException(
                "Twilio:AccountSid is not configured.");
        var authToken = config["Twilio:AuthToken"]
            ?? throw new InvalidOperationException(
                "Twilio:AuthToken is not configured.");
        // Prefer a Messaging Service when configured (Twilio picks the
        // approved WhatsApp sender from the service's pool). Falls back
        // to a bare WhatsApp From number for sandbox / single-sender
        // setups.
        _messagingServiceSid = config["Twilio:MessagingServiceSid"];
        _from = config["Twilio:WhatsAppFrom"];
        if (string.IsNullOrWhiteSpace(_messagingServiceSid)
            && string.IsNullOrWhiteSpace(_from))
        {
            throw new InvalidOperationException(
                "Twilio sender not configured: set Twilio:MessagingServiceSid "
                + "(preferred) or Twilio:WhatsAppFrom.");
        }

        // Approved WhatsApp authentication template SID (HX…). Required
        // for business-initiated messages outside the 24-hour conversation
        // window — Meta drops freeform text in that case. When unset, we
        // fall back to a bilingual freeform body (sandbox / in-window use).
        _contentSid = config["Twilio:ContentSid"];

        // Twilio uses HTTP Basic auth: AccountSid : AuthToken.
        var creds = Convert.ToBase64String(
            Encoding.ASCII.GetBytes($"{_accountSid}:{authToken}"));
        _http.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Basic", creds);
        if (_http.BaseAddress is null)
            _http.BaseAddress = new Uri("https://api.twilio.com/");
    }

    public async Task SendAsync(
        string phoneNumber,
        string otp,
        CancellationToken cancellationToken = default)
    {
        // Twilio expects the recipient as `whatsapp:+E.164`. The caller
        // already normalised the phone to canonical "+9627XXXXXXXX".
        var to = phoneNumber.StartsWith("whatsapp:",
                StringComparison.OrdinalIgnoreCase)
            ? phoneNumber
            : $"whatsapp:{phoneNumber}";

        var formData = new Dictionary<string, string>
        {
            ["To"] = to,
        };
        if (!string.IsNullOrWhiteSpace(_contentSid))
        {
            // Template-driven send: the body lives in the approved Meta
            // template referenced by ContentSid; we only fill in the OTP
            // variable. Authentication templates are single-variable —
            // {"1": "<otp>"} maps to {{1}} in the template body.
            formData["ContentSid"] = _contentSid;
            formData["ContentVariables"] = $"{{\"1\":\"{otp}\"}}";
        }
        else
        {
            // Freeform fallback for sandbox or within the 24-hour window.
            // Bilingual body — we don't know the recipient's locale at
            // OTP-request time, so include both. Same digits in both
            // halves so a misread always lands on the right code.
            formData["Body"] =
                $"رمز التحقق الخاص بك في تلمز باص: {otp}\n" +
                $"Your TilmezBus verification code: {otp}\n" +
                "(صالح لـ 5 دقائق · valid for 5 minutes)";
        }
        if (!string.IsNullOrWhiteSpace(_messagingServiceSid))
            formData["MessagingServiceSid"] = _messagingServiceSid;
        else
            formData["From"] = _from!;
        var form = new FormUrlEncodedContent(formData);

        var url = $"2010-04-01/Accounts/{_accountSid}/Messages.json";
        using var resp = await _http.PostAsync(url, form, cancellationToken);
        var respBody = await resp.Content
            .ReadAsStringAsync(cancellationToken);

        if (!resp.IsSuccessStatusCode)
        {
            _logger.LogWarning(
                "Twilio WhatsApp OTP send failed. Status={Status} Body={Body}",
                resp.StatusCode, respBody);
            throw new InvalidOperationException(
                $"WhatsApp OTP send failed: {resp.StatusCode}.");
        }

        _logger.LogInformation(
            "Sent WhatsApp OTP via Twilio. To={To}", to);
    }
}
