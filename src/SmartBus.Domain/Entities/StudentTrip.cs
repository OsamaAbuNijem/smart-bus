using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Entities;

public class StudentTrip : BaseEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = default!;
    public Guid TripId { get; set; }
    public Trip Trip { get; set; } = default!;
    public BoardingStatus BoardingStatus { get; set; } = BoardingStatus.Waiting;
    public DateTime? BoardingTime { get; set; }
    public DateTime? DropoffTime { get; set; }
}
