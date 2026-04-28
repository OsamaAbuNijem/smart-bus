using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Employees.Commands.RegisterFromQr;

/// <summary>
/// Self-registration: the user scans an employee QR and submits their details.
/// We resolve the school + role from the token, verify uniqueness on the phone
/// number within the relevant table, create the Driver/Assistant record, mint
/// an Identity user (password = "Otp@&lt;phone&gt;!" per the existing OTP scheme),
/// mark the token consumed, and hand back a JWT so the app skips the OTP step.
/// </summary>
public class RegisterFromQrCommandHandler
    : IRequestHandler<RegisterFromQrCommand, Result<RegisterFromQrResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly IUserStore _userStore;
    private readonly IJwtService _jwt;
    private readonly ILogger<RegisterFromQrCommandHandler> _logger;

    public RegisterFromQrCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        IUserStore userStore,
        IJwtService jwt,
        ILogger<RegisterFromQrCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
        _userStore  = userStore;
        _jwt        = jwt;
        _logger     = logger;
    }

    public async Task<Result<RegisterFromQrResponse>> Handle(
        RegisterFromQrCommand request, CancellationToken ct)
    {
        // ── Validate inputs ────────────────────────────────────────────────
        var token = (request.Token ?? string.Empty).Trim();
        var name  = (request.FullName ?? string.Empty).Trim();
        var phone = NormalizePhone(request.PhoneNumber);

        if (token.Length == 0) return Fail("Registration token is required.");
        if (name.Length  < 2 ) return Fail("Full name is required.");
        if (phone.Length < 7 ) return Fail("A valid phone number is required.");

        // ── Token lookup ───────────────────────────────────────────────────
        var qr = await _context.EmployeeQrTokens
            .Include(t => t.School)
            .FirstOrDefaultAsync(t => t.Token == token, ct);

        if (qr is null)             return Fail("Registration token not found.");
        if (qr.IsUsed)              return Fail("This QR has already been used to register an employee.");
        if (qr.School.IsDeleted)    return Fail("The school associated with this QR is no longer active.");
        if (!qr.School.IsActive)    return Fail("The school associated with this QR is currently inactive.");

        // ── Phone uniqueness — guard the right table for the token's type ──
        if (qr.Type == EmployeeQrTokenType.Driver)
        {
            if (await _unitOfWork.Drivers.GetByPhoneNumberAsync(phone, ct) is not null)
                return Fail("A driver with this phone number is already registered.");
        }
        else
        {
            if (await _unitOfWork.Assistants.GetByPhoneNumberAsync(phone, ct) is not null)
                return Fail("An assistant with this phone number is already registered.");
        }

        // ── Identity user (synthetic phone-based email, same as OTP login) ─
        var email = $"{phone}@smartbus.local";
        var role  = qr.Type == EmployeeQrTokenType.Driver ? "Driver" : "Assistant";
        var (_, createErr) = await _userStore.CreateUserIfNotExistsAsync(
            email, name, $"Otp@{phone}!", role, ct);
        if (createErr is not null) return Fail($"Could not create user account: {createErr}");

        var user = await _userStore.FindByEmailAsync(email, ct);
        if (user is null) return Fail("Failed to load the newly-created user account.");

        // ── Domain row + token consumption ─────────────────────────────────
        Guid employeeId;
        if (qr.Type == EmployeeQrTokenType.Driver)
        {
            var driver = new Driver
            {
                FullName    = name,
                PhoneNumber = phone,
                UserId      = user.Id,
                IsActive    = true,
                DriverType  = DriverType.Driver
            };
            await _unitOfWork.Drivers.AddAsync(driver, ct);
            await _unitOfWork.SaveChangesAsync(ct);
            employeeId = driver.Id;

            qr.UsedDriverId = driver.Id;
        }
        else
        {
            var assistant = new Assistant
            {
                FullName    = name,
                PhoneNumber = phone,
                UserId      = user.Id
            };
            await _unitOfWork.Assistants.AddAsync(assistant, ct);
            await _unitOfWork.SaveChangesAsync(ct);
            employeeId = assistant.Id;

            qr.UsedAssistantId = assistant.Id;
        }

        qr.IsUsed = true;
        qr.UsedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(ct);

        _logger.LogInformation(
            "[QrRegister] School={SchoolId} Type={Type} Phone={Phone} → Employee={EmpId}",
            qr.SchoolId, qr.Type, phone, employeeId);

        // ── JWT auto-login ─────────────────────────────────────────────────
        var jwt = _jwt.GenerateToken(user.Id, email, [role]);
        var exp = DateTime.UtcNow.AddHours(24);

        return Result<RegisterFromQrResponse>.Success(new RegisterFromQrResponse(
            jwt, exp, role, name, phone, employeeId));
    }

    private static Result<RegisterFromQrResponse> Fail(string message) =>
        Result<RegisterFromQrResponse>.Failure(message);

    private static string NormalizePhone(string? raw) =>
        new string((raw ?? string.Empty).Where(char.IsDigit).ToArray());
}
