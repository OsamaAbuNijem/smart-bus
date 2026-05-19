using TilmezBus.Domain.Common;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Domain.Entities;

/// <summary>
/// Append-only log of every push broadcast the SuperAdmin sends from the
/// platform's Notifications tab. Keeps a record of who fired what and
/// how many users were targeted — the per-recipient inbox rows still go
/// into the regular Notifications table.
/// </summary>
public class SuperAdminBroadcast : BaseEntity
{
    public string Title   { get; set; } = default!;
    public string Message { get; set; } = default!;

    public BroadcastTarget Target { get; set; }
    /// <summary>
    /// Comma-separated school IDs targeted (only meaningful when Target is
    /// SchoolUsers / SchoolAdmins). Stored as text for simplicity — query
    /// volume is low and we don't need to filter by these.
    /// </summary>
    public string? SchoolIdsCsv { get; set; }

    /// <summary>Number of users the broadcast was fanned out to.</summary>
    public int Recipients { get; set; }
    /// <summary>Number whose push device actually accepted the message.</summary>
    public int Delivered { get; set; }

    /// <summary>ApplicationUser.Id of the SuperAdmin who fired the broadcast.</summary>
    public string? SentByUserId { get; set; }
}
