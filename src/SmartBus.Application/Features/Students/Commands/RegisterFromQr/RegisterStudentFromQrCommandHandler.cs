using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Students.Commands.RegisterFromQr;

public class RegisterStudentFromQrCommandHandler
    : IRequestHandler<RegisterStudentFromQrCommand, Result<RegisterStudentFromQrResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly ILogger<RegisterStudentFromQrCommandHandler> _logger;

    public RegisterStudentFromQrCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        ICurrentUserService currentUser,
        ILogger<RegisterStudentFromQrCommandHandler> logger)
    {
        _unitOfWork  = unitOfWork;
        _context     = context;
        _currentUser = currentUser;
        _logger      = logger;
    }

    public async Task<Result<RegisterStudentFromQrResponse>> Handle(
        RegisterStudentFromQrCommand request, CancellationToken ct)
    {
        // ── Inputs ─────────────────────────────────────────────────────────
        var token  = (request.Token   ?? string.Empty).Trim();
        var name   = (request.FullName?? string.Empty).Trim();
        var grade  = (request.Grade   ?? string.Empty).Trim();

        if (token.Length == 0) return Fail("Registration token is required.");
        if (name.Length  < 2 ) return Fail("Student full name is required.");
        if (grade.Length == 0) return Fail("Student grade is required.");

        // ── Token lookup ───────────────────────────────────────────────────
        var qr = await _context.StudentQrTokens
            .Include(t => t.School)
            .FirstOrDefaultAsync(t => t.Token == token, ct);
        if (qr is null)              return Fail("Registration token not found.");
        if (qr.IsRegistered)         return Fail("This QR is already linked to a registered student.");
        if (qr.School.IsDeleted)     return Fail("The school associated with this QR is no longer active.");
        if (!qr.School.IsActive)     return Fail("The school associated with this QR is currently inactive.");

        // ── Parent identity ────────────────────────────────────────────────
        // The caller must be authenticated as a parent — pull their Parent row
        // via the JWT email (the OTP flow encodes the digits-only phone there).
        var email = _currentUser.UserName;
        if (string.IsNullOrEmpty(email))
            return Fail("Unauthenticated.");

        var phone  = email.Split('@')[0];
        var parent = await _unitOfWork.Parents.GetByPhoneNumberAsync(phone, ct);
        if (parent is null)
            return Fail("Only registered parents can register a student. Please log in as a parent first.");

        // ── Optional uniqueness check on national number ───────────────────
        var nationalNumber = (request.NationalNumber ?? string.Empty).Trim();
        if (nationalNumber.Length > 0)
        {
            var clash = await _context.Students
                .AnyAsync(s => s.NationalNumber == nationalNumber, ct);
            if (clash) return Fail("A student with this national number is already registered.");
        }

        // ── Create the Student row ─────────────────────────────────────────
        var student = new Student
        {
            FullName           = name,
            Grade              = grade,
            Class              = string.IsNullOrWhiteSpace(request.Class) ? null : request.Class!.Trim(),
            NationalNumber     = nationalNumber,
            SchoolId           = qr.SchoolId.ToString(),
            ParentId           = parent.Id,
            HomeArea           = request.HomeArea,
            HomeStreet         = request.HomeStreet,
            HomeBuildingNumber = request.HomeBuildingNumber,
            Latitude           = request.Latitude,
            Longitude          = request.Longitude
        };
        await _unitOfWork.Students.AddAsync(student, ct);
        await _unitOfWork.SaveChangesAsync(ct);

        // ── Bind the QR to the new student ─────────────────────────────────
        qr.IsRegistered = true;
        qr.RegisteredAt = DateTime.UtcNow;
        qr.StudentId    = student.Id;
        await _context.SaveChangesAsync(ct);

        _logger.LogInformation(
            "[StudentQrRegister] School={SchoolId} Parent={ParentId} → Student={StudentId} ({Token})",
            qr.SchoolId, parent.Id, student.Id, qr.Token);

        return Result<RegisterStudentFromQrResponse>.Success(
            new RegisterStudentFromQrResponse(
                student.Id, qr.Token, student.FullName, student.Grade,
                qr.SchoolId, qr.School.Name));
    }

    private static Result<RegisterStudentFromQrResponse> Fail(string message)
        => Result<RegisterStudentFromQrResponse>.Failure(message);
}
