using TilmezBus.Domain.Common;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Domain.Entities;

/// <summary>
/// Inbound "Request a demo" lead from the public landing page. Anyone can
/// submit one (no auth); the SuperAdmin sees the queue in their dashboard
/// and flips entries to Completed once they've reached out to the school.
/// </summary>
public class DemoRequest : BaseEntity
{
    public string SchoolName  { get; set; } = default!;
    public string ContactName { get; set; } = default!;
    public string Email       { get; set; } = default!;
    public string? PhoneNumber { get; set; }
    public string? Notes      { get; set; }

    public DemoRequestStatus Status { get; set; } = DemoRequestStatus.Pending;
    public DateTime? CompletedAt { get; set; }
    /// <summary>ApplicationUser.Id of the SuperAdmin who marked it completed.</summary>
    public string? CompletedByUserId { get; set; }
}
