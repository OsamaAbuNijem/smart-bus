using TilmezBus.Domain.Common;

namespace TilmezBus.Domain.Entities;

public class StudentAllergy : BaseEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = default!;
    public string Condition { get; set; } = default!;
}
