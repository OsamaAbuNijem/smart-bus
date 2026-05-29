using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Infrastructure.Services;

/// <summary>
/// Plain SMTP email transport built on the BCL's SmtpClient. Reads its
/// settings from <c>Email:*</c> config and authenticates against the
/// configured relay (Microsoft 365, Google Workspace, mailgun, etc.).
/// One client per send so the connection lifetime stays bounded.
/// </summary>
public sealed class SmtpEmailSender : IEmailSender
{
    private readonly ILogger<SmtpEmailSender> _logger;
    private readonly string _host;
    private readonly int    _port;
    private readonly string? _user;
    private readonly string? _password;
    private readonly bool   _useSsl;
    private readonly string _fromAddress;
    private readonly string _fromDisplay;

    public SmtpEmailSender(IConfiguration config, ILogger<SmtpEmailSender> logger)
    {
        _logger = logger;
        _host = config["Email:Host"]
            ?? throw new InvalidOperationException("Email:Host is not configured.");
        _port = int.TryParse(config["Email:Port"], out var p) ? p : 587;
        _user = config["Email:User"];
        _password = config["Email:Password"];
        _useSsl = !bool.TryParse(config["Email:UseSsl"], out var s) || s; // default true
        _fromAddress = config["Email:From"]
            ?? throw new InvalidOperationException("Email:From is not configured.");
        _fromDisplay = config["Email:FromDisplay"] ?? "TilmezBus";
    }

    public async Task SendAsync(string toEmail, string subject, string htmlBody, CancellationToken ct = default)
    {
        using var msg = new MailMessage
        {
            From = new MailAddress(_fromAddress, _fromDisplay),
            Subject = subject,
            Body = htmlBody,
            IsBodyHtml = true,
            BodyEncoding = System.Text.Encoding.UTF8,
            SubjectEncoding = System.Text.Encoding.UTF8,
        };
        msg.To.Add(new MailAddress(toEmail));

        using var smtp = new SmtpClient(_host, _port)
        {
            EnableSsl = _useSsl,
            DeliveryMethod = SmtpDeliveryMethod.Network,
            UseDefaultCredentials = false,
        };
        if (!string.IsNullOrWhiteSpace(_user))
            smtp.Credentials = new NetworkCredential(_user, _password ?? string.Empty);

        try
        {
            await smtp.SendMailAsync(msg, ct);
            _logger.LogInformation("Email sent to {To} (subject={Subject}).", toEmail, subject);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Failed to send email to {To} via {Host}:{Port}.", toEmail, _host, _port);
            throw;
        }
    }
}
