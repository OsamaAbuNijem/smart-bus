using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

/// <summary>
/// One-shot QR sticker the SuperAdmin prints when a school is created. Each
/// row represents a vacant student slot for that school.
///
/// Lifecycle:
///   • Phase 1 — first scan by a parent: registers the student. We populate
///     <see cref="StudentId"/>, flip <see cref="IsRegistered"/>, and persist
///     <see cref="RegisteredAt"/>. The token row stays alive (it is *not*
///     soft-deleted) so subsequent scans can still resolve it.
///   • Phase 2 — every later scan by the driver/assistant on the bus: the
///     token resolves to <see cref="StudentId"/> and is used to flip the
///     student's <see cref="StudentTrip"/> state on the active trip and
///     write an attendance row.
/// </summary>
public class StudentQrToken : BaseEntity
{
    /// <summary>Opaque value printed on the QR sticker (32-char hex).</summary>
    public string Token { get; set; } = default!;

    public Guid SchoolId { get; set; }
    public School School { get; set; } = default!;

    public bool IsRegistered { get; set; }
    public DateTime? RegisteredAt { get; set; }

    /// <summary>Set after the parent registers the student through this QR.</summary>
    public Guid? StudentId { get; set; }
    public Student? Student { get; set; }
}
