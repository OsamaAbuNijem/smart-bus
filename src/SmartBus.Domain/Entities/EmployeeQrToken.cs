using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Entities;

/// <summary>
/// One-shot QR sticker that the SuperAdmin prints when a school is created.
/// Each row represents a vacant Driver or Assistant slot for that school.
/// On scan, the mobile app uses the token to register the employee — name +
/// phone come from the form; the type comes from the token itself; the school
/// comes from the token's <see cref="SchoolId"/>. A single token can be
/// consumed exactly once.
/// </summary>
public class EmployeeQrToken : BaseEntity
{
    /// <summary>Opaque value printed on the QR sticker (32-char hex).</summary>
    public string Token { get; set; } = default!;

    public Guid SchoolId { get; set; }
    public School School { get; set; } = default!;

    public EmployeeQrTokenType Type { get; set; }

    public bool IsUsed { get; set; }
    public DateTime? UsedAt { get; set; }

    /// <summary>Set when Type=Driver and the token has been redeemed.</summary>
    public Guid? UsedDriverId { get; set; }

    /// <summary>Set when Type=Assistant and the token has been redeemed.</summary>
    public Guid? UsedAssistantId { get; set; }
}
