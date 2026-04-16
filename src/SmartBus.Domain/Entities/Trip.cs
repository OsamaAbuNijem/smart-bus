using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;
using SmartBus.Domain.Events;

namespace SmartBus.Domain.Entities;

public class Trip : BaseEntity
{
    public Guid BusId { get; set; }
    public Bus Bus { get; set; } = default!;
    public Guid RouteId { get; set; }
    public Route Route { get; set; } = default!;
    public DateTime ScheduledDeparture { get; set; }
    public DateTime? ActualDeparture { get; set; }
    public DateTime? ActualArrival { get; set; }
    public TripStatus Status { get; set; } = TripStatus.Scheduled;
    public string? Notes { get; set; }

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

    public void Cancel(string? reason = null)
    {
        Status = TripStatus.Cancelled;
        Notes = reason;
        AddDomainEvent(new TripStatusChangedEvent(Id, TripStatus.Cancelled));
    }
}
