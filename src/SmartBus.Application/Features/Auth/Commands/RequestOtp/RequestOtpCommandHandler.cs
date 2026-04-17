using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Auth.Commands.RequestOtp;

public class RequestOtpCommandHandler : IRequestHandler<RequestOtpCommand, Result<RequestOtpResponse>>
{
    private const int OtpTtlSeconds    = 300; // 5 minutes
    private const int MaxResendSeconds = 60;  // prevent spam: must wait 60 s before re-requesting

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

    public async Task<Result<RequestOtpResponse>> Handle(
        RequestOtpCommand request, CancellationToken cancellationToken)
    {
        var phone = request.PhoneNumber.Trim();
        var role  = request.Role.Trim();

        // ── Verify the phone belongs to the expected role ──────────────────
        var exists = role.ToLower() switch
        {
            "parent"    => await _unitOfWork.Parents.GetByPhoneNumberAsync(phone, cancellationToken)    is not null,
            "driver"    => await _unitOfWork.Drivers.GetByPhoneNumberAsync(phone, cancellationToken)    is not null,
            "assistant" => await _unitOfWork.Assistants.GetByPhoneNumberAsync(phone, cancellationToken) is not null,
            _           => false
        };

        if (!exists)
            return Result<RequestOtpResponse>.Failure(
                $"لم يتم العثور على رقم الجوال في النظام للدور '{role}'.");

        // ── Rate-limit: block re-request within 60 s ───────────────────────
        var cooldownKey = $"otp:cooldown:{role.ToLower()}:{phone}";
        if (await _cache.ExistsAsync(cooldownKey, cancellationToken))
            return Result<RequestOtpResponse>.Failure(
                "يرجى الانتظار دقيقة قبل طلب رمز جديد.");

        // ── Generate OTP ───────────────────────────────────────────────────
        var otp = GenerateOtp();

        // Store verifiable record
        var cacheKey = $"otp:{role.ToLower()}:{phone}";
        var record   = new OtpRecord(otp, DateTime.UtcNow, 0);
        await _cache.SetAsync(cacheKey, record, TimeSpan.FromSeconds(OtpTtlSeconds), cancellationToken);

        // Set cooldown
        await _cache.SetAsync(cooldownKey, true, TimeSpan.FromSeconds(MaxResendSeconds), cancellationToken);

        // ── Send OTP ───────────────────────────────────────────────────────
        await _sender.SendAsync(phone, otp, cancellationToken);

        // Always include OTP in result — the API controller strips it in Production
        return Result<RequestOtpResponse>.Success(
            new RequestOtpResponse("تم إرسال رمز التحقق بنجاح.", OtpTtlSeconds, otp));
    }

    private static string GenerateOtp()
        => Random.Shared.Next(100_000, 999_999).ToString();
}

internal record OtpRecord(string Code, DateTime CreatedAt, int Attempts);
