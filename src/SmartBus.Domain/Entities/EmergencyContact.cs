using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class EmergencyContact : BaseEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = default!;
    public string Name { get; set; } = default!;
    public string PhoneNumber { get; set; } = default!;
    public string? Relation { get; set; }
}
