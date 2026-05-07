using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Queries.GetMyTodayTrips;

/// <summary>
/// Today's trips for the current authenticated driver/assistant. One row per
/// (bus, leg) on the current driver's schedule — either an existing Trip
/// (in-progress / completed) or a placeholder for a scheduled-but-not-started leg.
/// </summary>
public record GetMyTodayTripsQuery() : IRequest<Result<List<MyTodayTripDto>>>;

public record MyTodayTripDto(
    Guid? TripId,            // null when leg not yet started
    Guid BusId,
    string BusPlateNumber,
    string TripType,         // "Morning" | "Return"
    string Status,           // "Scheduled" | "InProgress" | "Completed"
    DateTime ScheduledDeparture,
    DateTime? ActualDeparture,
    DateTime? ActualArrival,
    int StudentCount,
    int BoardedCount
);
