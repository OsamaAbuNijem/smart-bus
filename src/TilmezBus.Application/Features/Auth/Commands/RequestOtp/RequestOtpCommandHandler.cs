using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Auth.Commands.RequestOtp;

public class RequestOtpCommandHandler : IRequestHandler<RequestOtpCommand, Result<RequestOtpResponse>>
{
    private const int OtpTtlSeconds    = 300;
    private const int MaxResendSeconds = 60;

    private readonly IUnitOfWork   _unitOfWork;
    private readonly ICacheService _cache;
    private readonly IOtpSender    _sender;

    public RequestOtpCommandHandler(
        IUnitOfWork unitOfWork, ICacheService cache, IOtpSender sender)
    {
        _unitOfWork = unitOfWork;
        _cache      = cache;
        _sender     = sender;
    }

    private static string T(string ar, string en) =>
        System.Globalization.CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ar" ? ar : en;

    public async Task<Result<RequestOtpResponse>> Handle(
        RequestOtpCommand request, CancellationToken cancellationToken)
    {
        var phone = request.PhoneNumber.Trim();

        // Resolve the role from the phone. Parent first, then Driver/Assistant.
        // Drivers and Assistants share the Drivers table — DriverType disambiguates.
        string? role = null;

        var parent = await _unitOfWork.Parents.GetByPhoneNumberAsync(phone, cancellationToken);
        if (parent is not null) role = "Parent";

        if (role is null)
        {
            var driver = await _unitOfWork.Drivers.GetByPhoneNumberAsync(phone, cancellationToken);
            if (driver is not null)
            {
                role = driver.DriverType == DriverType.Assistant ? "Assistant" : "Driver";
            }
        }

        if (role is null)
            return Result<RequestOtpResponse>.Failure(
                T("لم يتم العثور على رقم الجوال في النظام.",
                  "Phone number not found in the system."));

        // ── Rate-limit: block re-request within 60 s ───────────────────────
        var cooldownKey = $"otp:cooldown:{role.ToLower()}:{phone}";
        if (await _cache.ExistsAsync(cooldownKey, cancellationToken))
            return Result<RequestOtpResponse>.Failure(
                T("يرجى الانتظار دقيقة قبل طلب رمز جديد.",
                  "Please wait a minute before requesting a new code."));

        var otp = GenerateOtp();

        var cacheKey = $"otp:{role.ToLower()}:{phone}";
        var record   = new OtpRecord(otp, DateTime.UtcNow, 0);
        await _cache.SetAsync(cacheKey, record, TimeSpan.FromSeconds(OtpTtlSeconds), cancellationToken);
        await _cache.SetAsync(cooldownKey, true, TimeSpan.FromSeconds(MaxResendSeconds), cancellationToken);

        await _sender.SendAsync(phone, otp, cancellationToken);

        return Result<RequestOtpResponse>.Success(
            new RequestOtpResponse(
                T("تم إرسال رمز التحقق بنجاح.", "Verification code sent successfully."),
                OtpTtlSeconds, role, otp));
    }

    private static string GenerateOtp()
        => Random.Shared.Next(1000, 10_000).ToString();
}

internal record OtpRecord(string Code, DateTime CreatedAt, int Attempts);
