using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class Driver : BaseEntity
{
    public string FullName { get; set; } = default!;
    public string PhoneNumber { get; set; } = default!;
    public string LicenseNumber { get; set; } = default!;
    public string? UserId { get; set; }
    public bool IsActive { get; set; } = true;

    public ICollection<Bus> Buses { get; set; } = new List<Bus>();
}
