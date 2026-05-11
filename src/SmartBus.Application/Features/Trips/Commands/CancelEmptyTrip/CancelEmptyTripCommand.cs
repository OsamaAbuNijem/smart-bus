using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.CancelEmptyTrip;

/// <summary>
/// Hard-delete a trip that has no students. Used by the assistant flow as
/// the "destructive sibling" of EndTrip: while the roster is empty there's
/// nothing to complete, so the assistant cancels the trip outright. As soon
/// as any student is attached (via mark / QR / NFC) the regular EndTrip
/// completion flow takes over.
/// </summary>
public record CancelEmptyTripCommand(Guid TripId) : IRequest<Result>;
