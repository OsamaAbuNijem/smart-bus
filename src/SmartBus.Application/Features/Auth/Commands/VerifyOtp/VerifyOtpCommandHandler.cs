using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Auth.Commands.RequestOtp;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Auth.Commands.VerifyOtp;

public class VerifyOtpCommandHandler : IRequestHandler<VerifyOtpCommand, Result<OtpLoginResponse>>
{
    private const int    MaxAttempts  = 5;
    private const string MasterDevOtp = "1234";

    private static bool IsDevEnvironment()
        => string.Equals(
            Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"),
            "Development",
            StringComparison.OrdinalIgnoreCase);

    private readonly IUnitOfWork  _unitOfWork;
    private readonly ICacheService _cache;
    private readonly IJwtService   _jwt;
    private readonly IUserStore    _userStore;

    public VerifyOtpCommandHandler(
        IUnitOfWork unitOfWork, ICacheService cache,
        IJwtService jwt, IUserStore userStore)
    {
        _unitOfWork = unitOfWork;
        _cache      = cache;
        _jwt        = jwt;
        _userStore  = userStore;
    }

    private static string T(string ar, string en) =>
        System.Globalization.CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ar" ? ar : en;

    public async Task<Result<OtpLoginResponse>> Handle(
        VerifyOtpCommand request, CancellationToken cancellationToken)
    {
        var phone    = request.PhoneNumber.Trim();
        var role     = request.Role.Trim();
        var otp      = request.Otp.Trim();
        var cacheKey = $"otp:{role.ToLower()}:{phone}";

        // ── Master OTP for development testing only ───────────────────────
        if (IsDevEnvironment() && otp == MasterDevOtp)
        {
            await _cache.RemoveAsync(cacheKey, cancellationToken);
            return role.ToLower() switch
            {
                "parent"    => await HandleParentAsync(phone, cancellationToken),
                "driver"    => await HandleDriverAsync(phone, cancellationToken),
                "assistant" => await HandleAssistantAsync(phone, cancellationToken),
                _           => Result<OtpLoginResponse>.Failure(T("دور غير معروف.", "Unknown role."))
            };
        }

        // ── Load OTP record ────────────────────────────────────────────────
        var record = await _cache.GetAsync<OtpRecord>(cacheKey, cancellationToken);
        if (record is null)
            return Result<OtpLoginResponse>.Failure(
                T("رمز التحقق منتهي الصلاحية أو غير موجود. يرجى طلب رمز جديد.",
                  "Verification code expired or not found. Please request a new code."));

        // ── Check attempt limit ────────────────────────────────────────────
        if (record.Attempts >= MaxAttempts)
        {
            await _cache.RemoveAsync(cacheKey, cancellationToken);
            return Result<OtpLoginResponse>.Failure(
                T("تم تجاوز الحد الأقصى للمحاولات. يرجى طلب رمز جديد.",
                  "Maximum attempts exceeded. Please request a new code."));
        }

        // ── Validate OTP ───────────────────────────────────────────────────
        if (record.Code != otp)
        {
            // Increment attempts
            var updated = record with { Attempts = record.Attempts + 1 };
            var remaining = (int)(record.CreatedAt.AddSeconds(300) - DateTime.UtcNow).TotalSeconds;
            if (remaining > 0)
                await _cache.SetAsync(cacheKey, updated, TimeSpan.FromSeconds(remaining), cancellationToken);

            var attemptsLeft = MaxAttempts - updated.Attempts;
            return Result<OtpLoginResponse>.Failure(
                T($"رمز التحقق غير صحيح. المحاولات المتبقية: {attemptsLeft}",
                  $"Invalid verification code. Remaining attempts: {attemptsLeft}"));
        }

        // ── OTP valid → remove from cache ──────────────────────────────────
        await _cache.RemoveAsync(cacheKey, cancellationToken);

        // ── Resolve entity and ensure Identity user exists ─────────────────
        return role.ToLower() switch
        {
            "parent"    => await HandleParentAsync(phone, cancellationToken),
            "driver"    => await HandleDriverAsync(phone, cancellationToken),
            "assistant" => await HandleAssistantAsync(phone, cancellationToken),
            _           => Result<OtpLoginResponse>.Failure(T("دور غير معروف.", "Unknown role."))
        };
    }

    // ── Per-role handlers ──────────────────────────────────────────────────

    private async Task<Result<OtpLoginResponse>> HandleParentAsync(
        string phone, CancellationToken ct)
    {
        var parent = await _unitOfWork.Parents.GetByPhoneNumberAsync(phone, ct);
        if (parent is null) return Result<OtpLoginResponse>.Failure(T("لم يتم العثور على ولي الأمر.", "Parent not found."));

        var (userId, err) = await EnsureUserAsync(parent.UserId, phone, parent.FullName, "Parent", ct);
        if (err is not null) return Result<OtpLoginResponse>.Failure(err);

        // Persist UserId link if newly created
        if (parent.UserId != userId)
        {
            parent.UserId = userId;
            await _unitOfWork.SaveChangesAsync(ct);
        }

        return BuildResponse(userId!, phone, parent.FullName, "Parent", parent.Id);
    }

    private async Task<Result<OtpLoginResponse>> HandleDriverAsync(
        string phone, CancellationToken ct)
    {
        var driver = await _unitOfWork.Drivers.GetByPhoneNumberAsync(phone, ct);
        if (driver is null) return Result<OtpLoginResponse>.Failure(T("لم يتم العثور على السائق.", "Driver not found."));

        var (userId, err) = await EnsureUserAsync(driver.UserId, phone, driver.FullName, "Driver", ct);
        if (err is not null) return Result<OtpLoginResponse>.Failure(err);

        if (driver.UserId != userId)
        {
            driver.UserId = userId;
            await _unitOfWork.SaveChangesAsync(ct);
        }

        return BuildResponse(userId!, phone, driver.FullName, "Driver", driver.Id);
    }

    private async Task<Result<OtpLoginResponse>> HandleAssistantAsync(
        string phone, CancellationToken ct)
    {
        var assistant = await _unitOfWork.Assistants.GetByPhoneNumberAsync(phone, ct);
        if (assistant is null) return Result<OtpLoginResponse>.Failure(T("لم يتم العثور على المساعد.", "Assistant not found."));

        var (userId, err) = await EnsureUserAsync(assistant.UserId, phone, assistant.FullName, "Assistant", ct);
        if (err is not null) return Result<OtpLoginResponse>.Failure(err);

        if (assistant.UserId != userId)
        {
            assistant.UserId = userId;
            await _unitOfWork.SaveChangesAsync(ct);
        }

        return BuildResponse(userId!, phone, assistant.FullName, "Assistant", assistant.Id);
    }

    // ── Helpers ────────────────────────────────────────────────────────────

    /// <summary>
    /// Returns the existing userId or creates a new Identity account for this
    /// phone-based user. Uses phone@smartbus.local as a synthetic email.
    /// </summary>
    private async Task<(string? UserId, string? Error)> EnsureUserAsync(
        string? existingUserId, string phone, string fullName,
        string role, CancellationToken ct)
    {
        if (!string.IsNullOrEmpty(existingUserId))
        {
            var existing = await _userStore.FindByEmailAsync(PhoneToEmail(phone), ct);
            if (existing is not null) return (existing.Id, null);
        }

        // Create a new Identity account — phone acts as unique identifier
        var email    = PhoneToEmail(phone);
        var password = $"Otp@{phone}!";           // internal password, never exposed
        var (_, createErr) = await _userStore.CreateUserIfNotExistsAsync(
            email, fullName, password, role, ct);

        if (createErr is not null) return (null, createErr);

        var user = await _userStore.FindByEmailAsync(email, ct);
        return user is not null ? (user.Id, null) : (null, T("فشل إنشاء حساب المستخدم.", "Failed to create user account."));
    }

    private Result<OtpLoginResponse> BuildResponse(
        string userId, string phone, string fullName, string role, Guid entityId)
    {
        var email = PhoneToEmail(phone);
        var token = _jwt.GenerateToken(userId, email, [role]);
        var exp   = DateTime.UtcNow.AddHours(24);
        return Result<OtpLoginResponse>.Success(
            new OtpLoginResponse(token, exp, role, fullName, phone, entityId));
    }

    private static string PhoneToEmail(string phone)
    {
        // Strip non-digits for a stable synthetic email
        var digits = new string(phone.Where(char.IsDigit).ToArray());
        return $"mob_{digits}@smartbus.local";
    }
}
