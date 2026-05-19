using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Schools.Commands.ResetSchoolAdminPassword;

public class ResetSchoolAdminPasswordCommandHandler
    : IRequestHandler<ResetSchoolAdminPasswordCommand, Result>
{
    private readonly IApplicationDbContext _context;
    private readonly IUserStore _userStore;

    public ResetSchoolAdminPasswordCommandHandler(
        IApplicationDbContext context,
        IUserStore userStore)
    {
        _context   = context;
        _userStore = userStore;
    }

    public async Task<Result> Handle(ResetSchoolAdminPasswordCommand request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.NewPassword))
            return Result.Failure("New password is required.");

        var school = await _context.Schools
            .Where(s => s.Id == request.SchoolId && !s.IsDeleted)
            .Select(s => new { s.AdminEmail, s.Name })
            .FirstOrDefaultAsync(cancellationToken);
        if (school is null)
            return Result.Failure("School not found.");
        if (string.IsNullOrWhiteSpace(school.AdminEmail))
            return Result.Failure("School has no admin email on file.");

        var (ok, error) = await _userStore.ResetPasswordByEmailAsync(
            school.AdminEmail, request.NewPassword, cancellationToken);
        return ok ? Result.Success() : Result.Failure(error ?? "Could not reset password.");
    }
}
