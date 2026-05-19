using TilmezBus.Domain.Common;

namespace TilmezBus.Domain.Events;

public record BusLocationUpdatedEvent(Guid BusId, double Latitude, double Longitude) : IDomainEvent;
