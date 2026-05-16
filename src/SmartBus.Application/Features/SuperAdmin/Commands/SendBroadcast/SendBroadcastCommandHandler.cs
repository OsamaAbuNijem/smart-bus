using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.SuperAdmin.Commands.SendBroadcast;

public class SendBroadcastCommandHandler
    : IRequestHandler<SendBroadcastCommand, Result<SendBroadcastResultDto>>
{
    private readonly IApplicationDbContext      _context;
    private readonly IUserStore                 _userStore;
    private readonly IPushNotificationService   _push;

    public SendBroadcastCommandHandler(
        IApplicationDbContext context,
        IUserStore userStore,
        IPushNotificationService push)
    {
        _context   = context;
        _userStore = userStore;
        _push      = push;
    }

    public async Task<Result<SendBroadcastResultDto>> Handle(SendBroadcastCommand request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Title) || string.IsNullOrWhiteSpace(request.Message))
            return Result<SendBroadcastResultDto>.Failure("Title and message are required.");

        // Resolve the recipient ApplicationUser ids. A HashSet collapses
        // overlap between an admin who also happens to be a parent.
        var recipients = await ResolveRecipientsAsync(request, cancellationToken);
        if (recipients.Count == 0)
            return Result<SendBroadcastResultDto>.Failure("No users matched the chosen audience.");

        // Fan out via the existing FCM service. SendToUserAsync writes the
        // notification to the inbox and returns the number of device
        // tokens the platform actually delivered to.
        var delivered = 0;
        foreach (var userId in recipients)
        {
            try
            {
                delivered += await _push.SendToUserAsync(
                    userId,
                    request.Title,
                    request.Message,
                    NotificationType.SystemAlert,
                    data: null,
                    cancellationToken);
            }
            catch
            {
                // Individual delivery failures shouldn't tank the whole
                // broadcast; the FCM service already prunes invalid tokens.
            }
        }

        var schoolCsv = request.SchoolIds.Count > 0
            ? string.Join(",", request.SchoolIds)
            : null;
        var broadcast = new SuperAdminBroadcast
        {
            Title        = request.Title.Trim(),
            Message      = request.Message.Trim(),
            Target       = request.Target,
            SchoolIdsCsv = schoolCsv,
            Recipients   = recipients.Count,
            Delivered    = delivered,
            SentByUserId = request.SentByUserId
        };
        _context.SuperAdminBroadcasts.Add(broadcast);
        await _context.SaveChangesAsync(cancellationToken);

        return Result<SendBroadcastResultDto>.Success(
            new SendBroadcastResultDto(broadcast.Id, recipients.Count, delivered));
    }

    /// <summary>
    /// Resolves the audience selector into a deduplicated set of
    /// ApplicationUser ids. Parents reach schools through their children;
    /// admins through the School.AdminEmail account; drivers / assistants
    /// only when the audience is AllUsers (no school FK on those tables).
    /// </summary>
    private async Task<HashSet<string>> ResolveRecipientsAsync(SendBroadcastCommand request, CancellationToken ct)
    {
        var ids = new HashSet<string>(StringComparer.Ordinal);

        switch (request.Target)
        {
            case BroadcastTarget.AllUsers:
                foreach (var role in new[] { "Parent", "Driver", "Assistant", "Admin" })
                    foreach (var id in await _userStore.GetUserIdsInRoleAsync(role, ct))
                        ids.Add(id);
                break;

            case BroadcastTarget.SchoolUsers:
                if (request.SchoolIds.Count == 0) break;
                var schoolIdSet     = request.SchoolIds.ToHashSet();
                var schoolIdStrings = request.SchoolIds.Select(g => g.ToString()).ToHashSet();

                // Admins of the picked schools — match via School.AdminEmail.
                var adminEmails = await _context.Schools
                    .Where(s => !s.IsDeleted && schoolIdSet.Contains(s.Id))
                    .Select(s => s.AdminEmail)
                    .ToListAsync(ct);
                foreach (var email in adminEmails)
                {
                    var u = await _userStore.FindByEmailAsync(email, ct);
                    if (u is not null) ids.Add(u.Id);
                }

                // Parents whose children attend the picked schools.
                // Student.SchoolId is stored as a string (Guid serialised),
                // hence the ToString conversion above.
                var parentUserIds = await _context.Parents
                    .Where(p => !p.IsDeleted
                             && p.UserId != null
                             && p.Children.Any(c => !c.IsDeleted && schoolIdStrings.Contains(c.SchoolId)))
                    .Select(p => p.UserId!)
                    .ToListAsync(ct);
                foreach (var id in parentUserIds) ids.Add(id);
                break;

            case BroadcastTarget.SchoolAdmins:
                if (request.SchoolIds.Count == 0)
                {
                    foreach (var id in await _userStore.GetUserIdsInRoleAsync("Admin", ct))
                        ids.Add(id);
                }
                else
                {
                    var pickedSchools   = request.SchoolIds.ToHashSet();
                    var pickedEmails    = await _context.Schools
                        .Where(s => !s.IsDeleted && pickedSchools.Contains(s.Id))
                        .Select(s => s.AdminEmail)
                        .ToListAsync(ct);
                    foreach (var email in pickedEmails)
                    {
                        var u = await _userStore.FindByEmailAsync(email, ct);
                        if (u is not null) ids.Add(u.Id);
                    }
                }
                break;
        }

        return ids;
    }
}
