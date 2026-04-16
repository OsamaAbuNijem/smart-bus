using SmartBus.Domain.Common;

namespace SmartBus.Domain.Events;

public record BusLocationUpdatedEvent(Guid BusId, double Latitude, double Longitude) : IDomainEvent;
