using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Parents.Queries.GetStudentTrips;

/// <summary>
/// Returns recent trips for one of the parent's children, with everything
/// the parent dashboard needs (pickup/dropoff labels, bus, driver, boarding
/// status, on-time/late/absent classification).
/// </summary>
public record GetStudentTripsQuery(
    Guid ParentId,
    Guid StudentId,
    int PageSize = 10) : IRequest<Result<List<StudentTripDetailDto>>>;

public record StudentTripDetailDto(
    Guid TripId,
    string TripType,            // "Morning" | "Return"
    DateTime TripDate,           // ScheduledDeparture (date+time)
    string BusPlateNumber,
    string? DriverName,
    string? AssistantName,
    string? RouteName,
    string PickupStopName,
    string DropoffStopName,
    DateTime ScheduledDeparture,
    DateTime? ActualDeparture,
    DateTime? ActualArrival,
    DateTime? BoardingTime,
    DateTime? DropoffTime,
    string BoardingStatus,       // "Waiting" | "Boarded" | "Absent"
    string TripStatus,           // "Scheduled" | "InProgress" | "Completed"
    int? DurationMinutes,
    int? DelayMinutes,
    string ResultTag             // "OnTime" | "Late" | "Absent" | "Pending"
);
