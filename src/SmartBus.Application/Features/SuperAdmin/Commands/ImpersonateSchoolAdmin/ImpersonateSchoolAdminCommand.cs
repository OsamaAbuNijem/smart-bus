using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.SuperAdmin.Commands.ImpersonateSchoolAdmin;

/// <summary>
/// SuperAdmin operation — mint a JWT for a school's admin user without
/// needing their password. The SA can then drop that token into their
/// browser session and operate the admin dashboard with full privileges,
/// returning to their SA session when finished.
/// </summary>
public record ImpersonateSchoolAdminCommand(Guid SchoolId)
    : IRequest<Result<ImpersonateResultDto>>;

public record ImpersonateResultDto(
    string Token,
    string Email,
    IReadOnlyList<string> Roles,
    Guid SchoolId,
    string SchoolName
);
