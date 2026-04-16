using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Entities;

public class Bus : BaseEntity
{
    public string PlateNumber { get; set; } = default!;
    public string Model { get; set; } = default!;
    public int Capacity { get; set; }
    public BusStatus Status { get; set; } = BusStatus.Inactive;
    public Guid? DriverId { get; set; }
    public Driver? Driver { get; set; }
    public ICollection<Trip> Trips { get; set; } = new List<Trip>();
    public BusLocation? LastLocation { get; set; }
}
