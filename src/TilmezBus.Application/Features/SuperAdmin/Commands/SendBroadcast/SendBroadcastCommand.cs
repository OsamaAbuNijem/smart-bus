using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.SuperAdmin.Commands.SendBroadcast;

/// <summary>
/// Fires a push notification from the SuperAdmin to an audience:
///   * AllUsers     — every Parent / Driver / Assistant / Admin
///   * SchoolUsers  — parents of children at the picked schools + the
///                    Admin user of each picked school
///   * SchoolAdmins — every Admin (filtered to the picked schools when
///                    <paramref name="SchoolIds"/> is non-empty)
/// </summary>
public record SendBroadcastCommand(
    string Title,
    string Message,
    BroadcastTarget Target,
    IReadOnlyList<Guid> SchoolIds,
    string? SentByUserId
) : IRequest<Result<SendBroadcastResultDto>>;

public record SendBroadcastResultDto(Guid BroadcastId, int Recipients, int Delivered);
