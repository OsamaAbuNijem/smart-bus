using System.ComponentModel.DataAnnotations.Schema;
using TilmezBus.Domain.Common;

namespace TilmezBus.Domain.Entities;

/// <summary>
/// One row per bus — stores the recurring trip schedule (ذهاب + إياب times and repeat days).
/// The Hangfire jobs read this table to generate daily Trip instances.
/// </summary>
public class BusSchedule : BaseEntity
{
    public Guid BusId { get; set; }

    [ForeignKey(nameof(BusId))]
    public Bus Bus { get; set; } = default!;

    /// <summary>Departure time for the morning trip (ذهاب), stored as UTC time-of-day.</summary>
    public TimeOnly MorningTime { get; set; }

    /// <summary>Departure time for the return trip (إياب), stored as UTC time-of-day.</summary>
    public TimeOnly ReturnTime { get; set; }

    /// <summary>Bitmask of active days: Sun=1, Mon=2, Tue=4, Wed=8, Thu=16, Fri=32, Sat=64.</summary>
    public byte RepeatDays { get; set; }

    public Guid? MorningDriverId { get; set; }

    [ForeignKey(nameof(MorningDriverId))]
    public Driver? MorningDriver { get; set; }

    public Guid? MorningAssistantId { get; set; }

    [ForeignKey(nameof(MorningAssistantId))]
    public Driver? MorningAssistant { get; set; }

    public Guid? ReturnDriverId { get; set; }

    [ForeignKey(nameof(ReturnDriverId))]
    public Driver? ReturnDriver { get; set; }

    public Guid? ReturnAssistantId { get; set; }

    [ForeignKey(nameof(ReturnAssistantId))]
    public Driver? ReturnAssistant { get; set; }

    /// <summary>Denormalized count of students on this schedule (updated when the schedule is saved).</summary>
    public int StudentCount { get; set; }

    public ICollection<BusScheduleStudent> Students { get; set; } = new List<BusScheduleStudent>();
}
