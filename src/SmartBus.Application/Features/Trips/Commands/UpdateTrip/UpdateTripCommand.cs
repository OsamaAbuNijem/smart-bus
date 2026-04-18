using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Commands.UpdateTrip;

public record UpdateTripCommand(
    Guid TripId,
    string Name,
    TripType Type,
    Guid BusId,
    Guid? RouteId,
    DateTime ScheduledDeparture,
    byte RepeatDays,
    string? Notes
) : IRequest<Result>;
