using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Commands.StartTrip;

/// <summary>
/// Create a new in-progress trip with the given bus, driver, and trip type.
/// The roster is copied from the most recent trip on (bus, type), or — if
/// none exists — from the BusSchedule's assigned students.
/// Used by the assistant flow: QR scan resolves a bus, but the trip itself
/// is only materialised here when the assistant taps "Start trip".
/// </summary>
public record StartTripCommand(
    Guid BusId,
    Guid DriverId,
    TripType TripType,
    bool SkipRoster = false
) : IRequest<Result<StartTripResponse>>;

public record StartTripResponse(
    Guid TripId,
    Guid BusId,
    string BusPlateNumber,
    string TripType,
    int StudentCount);
