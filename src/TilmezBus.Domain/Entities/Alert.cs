using TilmezBus.Domain.Common;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Domain.Entities;

public class Alert : BaseEntity
{
    public string Title { get; set; } = default!;
    public string Message { get; set; } = default!;
    public AlertSeverity Severity { get; set; } = AlertSeverity.Normal;
    public AlertStatus Status { get; set; } = AlertStatus.Pending;
    public Guid? RelatedBusId { get; set; }
    public Guid? RelatedTripId { get; set; }
    public Guid? RelatedStudentId { get; set; }

    public void Resolve() => Status = AlertStatus.ActionTaken;
    public void Ignore() => Status = AlertStatus.Ignored;
}
