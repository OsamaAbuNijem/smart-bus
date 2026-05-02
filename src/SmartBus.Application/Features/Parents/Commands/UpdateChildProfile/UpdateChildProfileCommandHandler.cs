using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Parents.Commands.UpdateChildProfile;

public class UpdateChildProfileCommandHandler : IRequestHandler<UpdateChildProfileCommand, Result>
{
    private readonly IApplicationDbContext _db;
    public UpdateChildProfileCommandHandler(IApplicationDbContext db) => _db = db;

    public async Task<Result> Handle(UpdateChildProfileCommand request, CancellationToken ct)
    {
        var student = await _db.Students
            .Where(s => s.Id == request.StudentId && s.ParentId == request.ParentId)
            .FirstOrDefaultAsync(ct);

        if (student is null)
            return Result.Failure("الطالب غير موجود لهذا الولي.");

        var fullName = request.FullName.Trim();
        if (string.IsNullOrEmpty(fullName))
            return Result.Failure("اسم الطالب مطلوب.");
        var grade = request.Grade.Trim();
        if (string.IsNullOrEmpty(grade))
            return Result.Failure("الصف مطلوب.");
        var parentName = request.ParentName.Trim();
        if (string.IsNullOrEmpty(parentName))
            return Result.Failure("اسم ولي الأمر مطلوب.");
        var parentPhone = request.ParentPhone.Trim();
        if (string.IsNullOrEmpty(parentPhone))
            return Result.Failure("رقم هاتف ولي الأمر مطلوب.");

        student.FullName = fullName;
        student.Grade = grade;
        student.Class = string.IsNullOrWhiteSpace(request.Class) ? null : request.Class!.Trim();
        student.Address = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes!.Trim();
        student.UpdatedAt = DateTime.UtcNow;

        var parent = await _db.Parents
            .FirstOrDefaultAsync(p => p.Id == request.ParentId, ct);
        if (parent is null) return Result.Failure("ولي الأمر غير موجود.");

        // If parent changes their phone we need to ensure no other parent uses it.
        if (!string.Equals(parent.PhoneNumber, parentPhone, StringComparison.Ordinal))
        {
            var phoneTaken = await _db.Parents
                .AnyAsync(p => p.Id != parent.Id && p.PhoneNumber == parentPhone, ct);
            if (phoneTaken)
                return Result.Failure("رقم الهاتف مستخدم لولي أمر آخر.");
            parent.PhoneNumber = parentPhone;
        }
        parent.FullName = parentName;
        parent.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);
        return Result.Success();
    }
}
