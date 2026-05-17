using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Entities;

public class Bus : BaseEntity
{
    public string PlateNumber { get; set; } = default!;
    public string? Model { get; set; }
    public int? ManufacturingYear { get; set; }
    public int Capacity { get; set; }
    public BusStatus Status { get; set; } = BusStatus.Inactive;
    public DateOnly? LastMaintenanceDate { get; set; }

    // School scope. Nullable for back-compat with rows that pre-date this
    // column; new buses are always created with a SchoolId stamped by the
    // calling admin's context.
    public Guid? SchoolId { get; set; }
    public School? School { get; set; }

    /// <summary>
    /// Opaque token printed on the bus's QR sticker. Drivers/assistants scan
    /// this from the mobile app to start a trip on demand. Generated once at
    /// bus-creation time and never reused.
    /// </summary>
    public string QrToken { get; set; } = default!;

    // Pointer to the most recent GPS location (updated on each location push)
    public Guid? LastLocationId { get; set; }
    public BusLocation? LastLocation { get; set; }

    public ICollection<Trip> Trips { get; set; } = new List<Trip>();
    public ICollection<BusLocation> BusLocations { get; set; } = new List<BusLocation>();
}
