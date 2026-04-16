using SmartBus.Domain.Common;
using SmartBus.Domain.Enums;

namespace SmartBus.Domain.Events;

public record TripStatusChangedEvent(Guid TripId, TripStatus NewStatus) : IDomainEvent;
