using System.ComponentModel.DataAnnotations.Schema;
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

    public Guid? DriverId { get; set; }
    [ForeignKey(nameof(DriverId))]
    public Driver? Driver { get; set; }

    // Assistant from the unified Driver entity (DriverType = Assistant)
    public Guid? AssistantDriverId { get; set; }
    [ForeignKey(nameof(AssistantDriverId))]
    public Driver? AssistantDriver { get; set; }

    public Guid? AssistantId { get; set; }
    public Assistant? Assistant { get; set; }

    // Pointer to the most recent GPS location (updated on each location push)
    public Guid? LastLocationId { get; set; }
    public BusLocation? LastLocation { get; set; }

    public ICollection<Trip> Trips { get; set; } = new List<Trip>();
    public ICollection<BusLocation> BusLocations { get; set; } = new List<BusLocation>();
}
