using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Common.Utilities;
using TilmezBus.Application.Features.Auth.Commands.RequestOtp;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Auth.Commands.VerifyOtp;

public class VerifyOtpCommandHandler : IRequestHandler<VerifyOtpCommand, Result<OtpLoginResponse>>
{
    private const string MasterDevOtp = "1234";

    private static bool IsDevEnvironment()
        => string.Equals(
            Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"),
            "Development",
            StringComparison.OrdinalIgnoreCase);

    private readonly IUnitOfWork   _unitOfWork;
    private readonly ICacheService _cache;
    private readonly IJwtService   _jwt;
    private readonly IUserStore    _userStore;
    private readonly IOtpSender    _otp;

    public VerifyOtpCommandHandler(
        IUnitOfWork unitOfWork, ICacheService cache,
        IJwtService jwt, IUserStore userStore, IOtpSender otp)
    {
        _unitOfWork = unitOfWork;
        _cache      = cache;
        _jwt        = jwt;
        _userStore  = userStore;
        _otp        = otp;
    }

    private static string T(string ar, string en) =>
        System.Globalization.CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ar" ? ar : en;

    public async Task<Result<OtpLoginResponse>> Handle(
        VerifyOtpCommand request, CancellationToken cancellationToken)
    {
        var phone = PhoneNumberHelper.Normalize(request.PhoneNumber.Trim());
        var otp   = request.Otp.Trim();

        // Resolve role from the phone — must match what RequestOtp resolved.
        var resolvedRole = await ResolveRoleAsync(phone, cancellationToken);
        if (resolvedRole is null)
            return Result<OtpLoginResponse>.Failure(
                T("لم يتم العثور على رقم الجوال في النظام.",
                  "Phone number not found in the system."));

        var cooldownKey = $"otp:cooldown:{resolvedRole.ToLower()}:{phone}";

        // Master OTP for development testing only.
        if (IsDevEnvironment() && otp == MasterDevOtp)
        {
            await _cache.RemoveAsync(cooldownKey, cancellationToken);
            return await DispatchAsync(resolvedRole, phone, cancellationToken);
        }

        // Delegate validation, expiry, and attempt-count enforcement to
        // Twilio Verify; we only see approved / not-approved.
        var approved = await _otp.VerifyAsync(phone, otp, cancellationToken);
        if (!approved)
        {
            return Result<OtpLoginResponse>.Failure(
                T("رمز التحقق غير صحيح أو منتهي الصلاحية.",
                  "Invalid or expired verification code."));
        }

        // OTP consumed → drop the resend cooldown so a post-logout
        // re-login can request a fresh code immediately.
        await _cache.RemoveAsync(cooldownKey, cancellationToken);
        return await DispatchAsync(resolvedRole, phone, cancellationToken);
    }

    private async Task<string?> ResolveRoleAsync(string phone, CancellationToken ct)
    {
        var parent = await _unitOfWork.Parents.GetByPhoneNumberAsync(phone, ct);
        if (parent is not null) return "Parent";
        var driver = await _unitOfWork.Drivers.GetByPhoneNumberAsync(phone, ct);
        if (driver is null) return null;
        return driver.DriverType == TilmezBus.Domain.Enums.DriverType.Assistant
            ? "Assistant" : "Driver";
    }

    private Task<Result<OtpLoginResponse>> DispatchAsync(
        string role, string phone, CancellationToken ct) => role switch
        {
            "Parent"    => HandleParentAsync(phone, ct),
            "Driver"    => HandleDriverAsync(phone, ct),
            "Assistant" => HandleAssistantAsync(phone, ct),
            _           => Task.FromResult(
                Result<OtpLoginResponse>.Failure(T("دور غير معروف.", "Unknown role."))),
        };

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
        // Assistants are stored in the Drivers table with DriverType=Assistant.
        var driver = await _unitOfWork.Drivers.GetByPhoneNumberAsync(phone, ct);
        if (driver is null || driver.DriverType != TilmezBus.Domain.Enums.DriverType.Assistant)
            return Result<OtpLoginResponse>.Failure(T("لم يتم العثور على المساعد.", "Assistant not found."));

        var (userId, err) = await EnsureUserAsync(driver.UserId, phone, driver.FullName, "Assistant", ct);
        if (err is not null) return Result<OtpLoginResponse>.Failure(err);

        if (driver.UserId != userId)
        {
            driver.UserId = userId;
            await _unitOfWork.SaveChangesAsync(ct);
        }

        return BuildResponse(userId!, phone, driver.FullName, "Assistant", driver.Id);
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
        // Canonicalise first so the synthetic email is stable across input
        // shapes: "793333333", "0793333333" and "+962793333333" all produce
        // the same "mob_962793333333@smartbus.local" address. Without this
        // step the OTP-verify creates a fresh AspNetUsers row per shape and
        // Drivers.UserId drifts out of sync with the JWT subject.
        var canonical = PhoneNumberHelper.Normalize(phone);
        var digits    = new string(canonical.Where(char.IsDigit).ToArray());
        return $"mob_{digits}@smartbus.local";
    }
}
