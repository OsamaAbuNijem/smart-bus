using TilmezBus.Domain.Common;
using TilmezBus.Domain.Enums;
using TilmezBus.Domain.Events;

namespace TilmezBus.Domain.Entities;

public class Trip : BaseEntity
{
    public string Name { get; set; } = default!;
    public TripType Type { get; set; }
    public Guid BusId { get; set; }
    public Bus Bus { get; set; } = default!;
    // Denormalized from Bus.SchoolId to pin the trip to its school at
    // creation time (survives a future bus-transfer feature, simpler tenant
    // queries).
    public Guid? SchoolId { get; set; }
    public School? School { get; set; }
    public Guid? DriverId { get; set; }
    public Driver? Driver { get; set; }
    // Assistants are stored in Drivers with DriverType.Assistant; this FK
    // records who actually ran the trip (vs. BusSchedule's scheduled one).
    public Guid? AssistantId { get; set; }
    public Driver? Assistant { get; set; }
    public DateTime ScheduledDeparture { get; set; }
    public DateTime? ActualDeparture { get; set; }
    public DateTime? ActualArrival { get; set; }
    public TripStatus Status { get; set; } = TripStatus.Scheduled;

    /// <summary>Bitmask: 1=Sun,2=Mon,4=Tue,8=Wed,16=Thu,32=Fri,64=Sat</summary>
    public byte RepeatDays { get; set; }

    public string? Notes { get; set; }

    /// <summary>
    /// True = recurring schedule template (set by admin via bus schedule modal).
    /// False = a concrete daily trip instance created by the generation job.
    /// </summary>
    public bool IsTemplate { get; set; } = false;

    public ICollection<StudentTrip> StudentTrips { get; set; } = new List<StudentTrip>();

    public void Start()
    {
        Status = TripStatus.InProgress;
        ActualDeparture = DateTime.UtcNow;
        AddDomainEvent(new TripStatusChangedEvent(Id, TripStatus.InProgress));
    }

    public void Complete()
    {
        Status = TripStatus.Completed;
        ActualArrival = DateTime.UtcNow;
        AddDomainEvent(new TripStatusChangedEvent(Id, TripStatus.Completed));
    }
}
