using SmartBus.Domain.Common;

namespace SmartBus.Domain.Entities;

public class School : BaseEntity
{
    public string Name { get; set; } = default!;
    public string City { get; set; } = default!;
    public string ContactEmail { get; set; } = default!;
    public string PhoneNumber { get; set; } = default!;
    public string AdminEmail { get; set; } = default!;
    public string? LogoUrl { get; set; }
    public string? Notes { get; set; }

    /// <summary>
    /// School map location supplied by the SuperAdmin. Used by the driver
    /// route map as the start (Return trips) or end (Morning trips).
    /// </summary>
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
}
