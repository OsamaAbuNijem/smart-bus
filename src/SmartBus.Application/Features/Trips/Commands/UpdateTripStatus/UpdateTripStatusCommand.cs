using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Commands.UpdateTripStatus;

public record UpdateTripStatusCommand(Guid TripId, TripStatus NewStatus, string? Notes = null) : IRequest<Result>;
