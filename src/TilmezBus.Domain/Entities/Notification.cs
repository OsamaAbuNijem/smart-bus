using TilmezBus.Domain.Common;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Domain.Entities;

public class Notification : BaseEntity
{
    public string Title { get; set; } = default!;
    public string Message { get; set; } = default!;
    public NotificationType Type { get; set; }
    public bool IsRead { get; set; } = false;
    public string? RecipientId { get; set; }
    public Guid? RelatedTripId { get; set; }
    public Guid? RelatedBusId { get; set; }
}
