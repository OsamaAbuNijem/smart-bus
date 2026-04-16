using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class Parent : BaseEntity
{
    public string FullName { get; set; } = default!;
    public string PhoneNumber { get; set; } = default!;
    public string? UserId { get; set; }

    public ICollection<Student> Children { get; set; } = new List<Student>();
}
