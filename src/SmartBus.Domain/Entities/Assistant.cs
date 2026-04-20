using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class Assistant : BaseEntity
{
    public string FullName { get; set; } = default!;
    public string PhoneNumber { get; set; } = default!;
    public string? UserId { get; set; }
}
