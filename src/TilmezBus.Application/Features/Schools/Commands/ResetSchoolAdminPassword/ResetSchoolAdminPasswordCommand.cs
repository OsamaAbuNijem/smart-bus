using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Schools.Commands.ResetSchoolAdminPassword;

/// <summary>
/// SuperAdmin operation — force-reset a school admin's password. The
/// admin is identified by the School.AdminEmail recorded on the School
/// row; no current password is required.
/// </summary>
public record ResetSchoolAdminPasswordCommand(
    Guid SchoolId,
    string NewPassword
) : IRequest<Result>;
