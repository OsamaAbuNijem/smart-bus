using TilmezBus.Domain.Common;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Domain.Events;

public record TripStatusChangedEvent(Guid TripId, TripStatus NewStatus) : IDomainEvent;
