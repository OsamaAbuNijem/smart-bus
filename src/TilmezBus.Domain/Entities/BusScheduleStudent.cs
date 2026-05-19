namespace TilmezBus.Domain.Entities;

/// <summary>
/// Join table — the students assigned to a bus's recurring schedule (ذهاب/إياب).
/// Composite key (BusScheduleId, StudentId).
/// </summary>
public class BusScheduleStudent
{
    public Guid BusScheduleId { get; set; }
    public BusSchedule BusSchedule { get; set; } = default!;

    public Guid StudentId { get; set; }
    public Student Student { get; set; } = default!;
}
