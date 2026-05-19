using TilmezBus.Domain.Common;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Domain.Entities;

public class AbsenceRequest : BaseEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = default!;
    public DateOnly Date { get; set; }
    public AbsenceTripType TripType { get; set; }
    public AbsenceReason Reason { get; set; }
    public string? PickupPersonName { get; set; }
    public string? PickupPersonRelation { get; set; }
    public string? DriverNote { get; set; }
    public bool NotifyDriver { get; set; } = true;
    public bool NotifySchool { get; set; } = true;
    public AbsenceRequestStatus Status { get; set; } = AbsenceRequestStatus.Pending;
}
