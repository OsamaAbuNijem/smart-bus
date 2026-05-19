using TilmezBus.Domain.Common;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Domain.Entities;

public class Attendance : BaseEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = default!;
    public Guid TripId { get; set; }
    public Trip Trip { get; set; } = default!;
    public DateOnly Date { get; set; }
    public AttendanceStatus Status { get; set; } = AttendanceStatus.Absent;
    public DateTime? BoardingTime { get; set; }
    public DateTime? DropoffTime { get; set; }
}
