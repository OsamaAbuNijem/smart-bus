using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;
using SmartBus.Domain.Events;

namespace SmartBus.Domain.Entities;

public class Trip : BaseEntity
{
    public string Name { get; set; } = default!;
    public TripType Type { get; set; }
    public Guid BusId { get; set; }
    public Bus Bus { get; set; } = default!;
    public Guid? RouteId { get; set; }
    public Route? Route { get; set; }
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
    public ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();

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
