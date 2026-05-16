using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.SuperAdmin.Commands.ImpersonateSchoolAdmin;

public class ImpersonateSchoolAdminCommandHandler
    : IRequestHandler<ImpersonateSchoolAdminCommand, Result<ImpersonateResultDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly IUserStore _userStore;
    private readonly IJwtService _jwt;

    public ImpersonateSchoolAdminCommandHandler(
        IApplicationDbContext context,
        IUserStore userStore,
        IJwtService jwt)
    {
        _context   = context;
        _userStore = userStore;
        _jwt       = jwt;
    }

    public async Task<Result<ImpersonateResultDto>> Handle(ImpersonateSchoolAdminCommand request, CancellationToken cancellationToken)
    {
        var school = await _context.Schools
            .Where(s => s.Id == request.SchoolId && !s.IsDeleted)
            .Select(s => new { s.Id, s.Name, s.AdminEmail })
            .FirstOrDefaultAsync(cancellationToken);
        if (school is null)
            return Result<ImpersonateResultDto>.Failure("School not found.");
        if (string.IsNullOrWhiteSpace(school.AdminEmail))
            return Result<ImpersonateResultDto>.Failure("School has no admin email on file.");

        var admin = await _userStore.FindByEmailAsync(school.AdminEmail, cancellationToken);
        // Self-heal: schools created in earlier dev iterations can have a
        // valid AdminEmail on the school row but no matching Identity user
        // (the row was deleted, or the email was edited away). The SA has
        // authority over schools, so we silently mint the admin user with a
        // random password + Admin role. The SA can use the grid's "Reset
        // admin password" action to assign a real password afterwards.
        if (admin is null)
        {
            var seedPassword = $"Tmp!{Guid.NewGuid():N}A1";
            var (_, createErr) = await _userStore.CreateUserIfNotExistsAsync(
                school.AdminEmail,
                school.Name + " Admin",
                seedPassword,
                "Admin",
                cancellationToken);
            if (createErr is not null)
                return Result<ImpersonateResultDto>.Failure($"Could not provision admin account: {createErr}");
            admin = await _userStore.FindByEmailAsync(school.AdminEmail, cancellationToken);
            if (admin is null)
                return Result<ImpersonateResultDto>.Failure("Admin account could not be provisioned for this school.");
        }

        var roles = (await _userStore.GetRolesAsync(admin.Id, cancellationToken)).ToList();
        if (!roles.Contains("Admin"))
            return Result<ImpersonateResultDto>.Failure("Target user is not a school admin.");

        // Reuse the same JwtService the regular login flow uses so the token
        // carries the standard claim set and the admin endpoints accept it.
        var token = _jwt.GenerateToken(admin.Id, admin.Email, roles);
        return Result<ImpersonateResultDto>.Success(
            new ImpersonateResultDto(token, admin.Email, roles, school.Id, school.Name));
    }
}
