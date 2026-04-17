using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.DeleteTrip;

public record DeleteTripCommand(Guid TripId) : IRequest<Result>;
