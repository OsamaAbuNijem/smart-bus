using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Entities;

public class Driver : BaseEntity
{
    public string FullName { get; set; } = default!;
    public string? FullNameEn { get; set; }
    public string PhoneNumber { get; set; } = default!;
    public string? UserId { get; set; }
    public bool IsActive { get; set; } = true;
    public DriverType DriverType { get; set; } = DriverType.Driver;
}
