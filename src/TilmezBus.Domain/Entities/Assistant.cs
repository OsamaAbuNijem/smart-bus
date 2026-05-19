using TilmezBus.Domain.Common;

namespace TilmezBus.Domain.Entities;

public class Assistant : BaseEntity
{
    public string FullName { get; set; } = default!;
    public string PhoneNumber { get; set; } = default!;
    public string? UserId { get; set; }

    // School scope. Mirrors Driver/Bus — see those entities for rationale.
    public Guid? SchoolId { get; set; }
    public School? School { get; set; }
}
