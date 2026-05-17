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
    bool SkipRoster = false,
    // When non-empty, overrides the auto-roster (last trip / schedule) so the
    // assistant can hand-pick the students for this leg. Ignored when
    // SkipRoster is true — the assistant's explicit "no students" wins.
    IReadOnlyList<Guid>? ManualStudentIds = null,
    // When true the trip is materialised in Scheduled status (not started).
    // The assistant then explicitly flips it to InProgress later via the
    // /trips/{id}/start endpoint. Used by the two-step new-trip flow.
    bool Scheduled = false
) : IRequest<Result<StartTripResponse>>;

public record StartTripResponse(
    Guid TripId,
    Guid BusId,
    string BusPlateNumber,
    string TripType,
    int StudentCount);
