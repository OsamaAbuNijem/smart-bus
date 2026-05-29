using MediatR;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.RequestPasswordReset;

public class RequestPasswordResetCommandHandler
    : IRequestHandler<RequestPasswordResetCommand, Result>
{
    private readonly IUserStore     _userStore;
    private readonly IEmailSender   _email;
    private readonly IConfiguration _config;
    private readonly ILogger<RequestPasswordResetCommandHandler> _logger;

    public RequestPasswordResetCommandHandler(
        IUserStore userStore, IEmailSender email,
        IConfiguration config, ILogger<RequestPasswordResetCommandHandler> logger)
    {
        _userStore = userStore;
        _email     = email;
        _config    = config;
        _logger    = logger;
    }

    public async Task<Result> Handle(
        RequestPasswordResetCommand request, CancellationToken ct)
    {
        var email = request.Email?.Trim();
        if (string.IsNullOrWhiteSpace(email))
            return Result.Failure("Email is required.");

        var token = await _userStore.GeneratePasswordResetTokenAsync(email, ct);
        // Never tell the caller whether the email exists — generic success
        // either way so an attacker can't enumerate accounts.
        if (token is null)
        {
            _logger.LogInformation(
                "Password reset requested for unknown email {Email}; ignoring.", email);
            return Result.Success();
        }

        // Identity tokens contain base64 + `/+=` characters; URL-encode the
        // whole link so neither the email + token round-trips broken.
        var baseUrl = (_config["App:BaseUrl"] ?? "https://tilmezbus.com")
            .TrimEnd('/');
        var encodedEmail = Uri.EscapeDataString(email);
        var encodedToken = Uri.EscapeDataString(token);
        var link = $"{baseUrl}/Account/ResetPassword?email={encodedEmail}&token={encodedToken}";

        var subject = "إعادة تعيين كلمة المرور — TilmezBus / Reset your TilmezBus password";
        var html = BuildEmailHtml(email, link);

        try
        {
            await _email.SendAsync(email, subject, html, ct);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Failed to send password-reset email to {Email}.", email);
            // Still report success to the caller — we don't want to leak
            // delivery state. Operators will see the log.
        }
        return Result.Success();
    }

    /// <summary>Bilingual HTML body (ar + en) with a single CTA pointing
    /// at the reset page. Inline styles only so most mail clients render
    /// it consistently without external CSS.</summary>
    private static string BuildEmailHtml(string toEmail, string link)
        => $"""
            <!DOCTYPE html>
            <html lang="ar" dir="rtl">
            <head>
              <meta charset="utf-8" />
              <meta name="viewport" content="width=device-width,initial-scale=1" />
              <title>TilmezBus — Password reset</title>
            </head>
            <body style="margin:0;background:#f4f4f5;font-family:Tahoma,'Segoe UI',Arial,sans-serif;color:#0f172a;">
              <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%" style="background:#f4f4f5;padding:32px 12px;">
                <tr><td align="center">
                  <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="560" style="max-width:560px;background:#ffffff;border-radius:16px;padding:28px;">
                    <tr><td>
                      <div style="font-size:22px;font-weight:800;letter-spacing:-0.3px;color:#0f172a;">TilmezBus</div>
                      <div style="height:12px"></div>
                      <hr style="border:none;border-top:1px solid #e5e7eb;margin:0 0 18px 0" />

                      <p style="margin:0 0 12px 0;font-size:15px;line-height:1.6;">
                        طلبنا منك إعادة تعيين كلمة المرور لحسابك في تلمز باص.
                        اضغط الزر أدناه لاختيار كلمة مرور جديدة. هذا الرابط
                        صالح لمدة ساعة واحدة فقط.
                      </p>

                      <p style="margin:0 0 18px 0;direction:ltr;text-align:left;font-size:15px;line-height:1.6;color:#475569;">
                        We received a request to reset the password for your TilmezBus
                        account. Click the button below to choose a new password.
                        This link is valid for one hour.
                      </p>

                      <p style="text-align:center;margin:18px 0 22px 0;">
                        <a href="{link}" style="display:inline-block;background:#FACC15;color:#0f172a;text-decoration:none;font-weight:800;padding:12px 26px;border-radius:12px;letter-spacing:-0.2px;">
                          Reset password / إعادة تعيين
                        </a>
                      </p>

                      <p style="margin:0 0 6px 0;direction:ltr;text-align:left;font-size:12px;color:#64748b;">
                        If the button doesn't work, paste this URL into your browser:
                      </p>
                      <p style="margin:0 0 18px 0;word-break:break-all;direction:ltr;text-align:left;font-size:12px;color:#0ea5e9;">
                        <a href="{link}" style="color:#0ea5e9;text-decoration:underline;">{link}</a>
                      </p>

                      <hr style="border:none;border-top:1px solid #e5e7eb;margin:18px 0" />
                      <p style="margin:0;font-size:12px;color:#64748b;line-height:1.6;">
                        إذا لم تطلب إعادة تعيين كلمة المرور، فيمكنك تجاهل هذا
                        البريد بأمان.<br/>
                        <span style="direction:ltr;display:inline-block">If you didn't request a reset, you can safely ignore this email.</span>
                      </p>
                    </td></tr>
                  </table>
                  <div style="height:14px"></div>
                  <div style="font-size:11px;color:#94a3b8;">{toEmail}</div>
                </td></tr>
              </table>
            </body>
            </html>
            """;
}
