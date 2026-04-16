using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class StudentAllergy : BaseEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = default!;
    public string Condition { get; set; } = default!;
}
