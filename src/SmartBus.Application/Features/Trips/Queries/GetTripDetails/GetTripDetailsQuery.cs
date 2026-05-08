using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Queries.GetTripDetails;

/// <summary>
/// Rich trip view for the assistant's live trip-details screen. Includes the
/// trip header (bus, driver, started time, totals) plus per-student rows with
/// parent contact info, location, and absence flag.
/// </summary>
public record GetTripDetailsQuery(Guid TripId)
    : IRequest<Result<TripDetailsDto>>;

public record TripDetailsDto(
    Guid TripId,
    string TripType,        // "Morning" | "Return"
    string Status,          // "InProgress" | "Completed" | ...
    string BusPlateNumber,
    string? DriverName,
    DateTime ScheduledDeparture,
    DateTime? ActualDeparture,
    DateTime? ActualArrival,
    int StudentCount,
    int BoardedCount,
    List<TripStudentDetailDto> Students);

public record TripStudentDetailDto(
    Guid StudentId,
    string FullName,
    string? FullNameEn,
    string Grade,
    string? Class,
    string? HomeArea,
    double? Latitude,
    double? Longitude,
    string BoardingStatus,  // "Waiting" | "Boarded" | "Absent"
    DateTime? BoardingTime,
    DateTime? DropoffTime,
    bool IsAbsentToday,
    string? AbsenceReason,        // "Illness" | "MedicalAppointment" | "FamilyMatter" | "Other"
    string? AbsencePickupPersonName,
    string? AbsencePickupPersonRelation,
    string? AbsenceDriverNote,
    string? ParentName,
    string? ParentPhone);
