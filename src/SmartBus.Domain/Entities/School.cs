using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Entities;

public class School : BaseEntity
{
    public string Name { get; set; } = default!;
    public string City { get; set; } = default!;
    public string ContactEmail { get; set; } = default!;
    public string PhoneNumber { get; set; } = default!;
    public string AdminEmail { get; set; } = default!;
    public PlanType Plan { get; set; } = PlanType.Basic;
    public int MaxBuses { get; set; } = 5;
    public int MaxDrivers { get; set; } = 5;
    public int MaxAssistants { get; set; } = 5;
    public int MaxStudents { get; set; } = 100;
    public bool IsActive { get; set; } = true;
    public string? LogoUrl { get; set; }
    public string? Notes { get; set; }

    /// <summary>
    /// School map location supplied by the SuperAdmin. Used by the driver
    /// route map as the start (Return trips) or end (Morning trips).
    /// </summary>
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
}
