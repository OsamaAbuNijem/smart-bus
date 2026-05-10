using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Parents.Queries.GetLiveTracking;

/// <summary>
/// Snapshot for the parent's live-tracking screen — the latest in-progress
/// (or most-recent) trip for the child, with bus position, crew + phones,
/// and home / school locations.
/// </summary>
public record GetLiveTrackingQuery(Guid ParentId, Guid StudentId)
    : IRequest<Result<LiveTrackingDto>>;

public record LiveTrackingDto(
    Guid? TripId,
    string? TripStatus,         // Scheduled | InProgress | Completed
    string? TripType,           // Morning | Return
    DateTime? ScheduledDeparture,
    DateTime? ActualDeparture,
    DateTime? ActualArrival,
    DateTime? BoardingTime,
    string? BoardingStatus,     // Waiting | Boarded | Absent
    Guid? BusId,
    string? BusPlateNumber,
    BusLocationDto? BusLocation,
    string? DriverName,
    string? DriverPhone,
    string? AssistantName,
    string? AssistantPhone,
    string StudentFullName,
    double? HomeLatitude,
    double? HomeLongitude,
    string? HomeAddress,
    string? SchoolName,
    double? SchoolLatitude,
    double? SchoolLongitude);

public record BusLocationDto(
    double Latitude,
    double Longitude,
    double? Speed,
    double? Heading,
    DateTime Timestamp);
