using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Buses.Queries.GetBusLastRoster;

/// <summary>
/// Roster for the most recent trip on this bus with the given trip type.
/// Falls back to the BusSchedule's assigned students if no prior trip exists.
/// Used by the assistant trip-setup screen to preview the students that will
/// be loaded onto the new trip.
/// </summary>
public record GetBusLastRosterQuery(Guid BusId, TripType TripType)
    : IRequest<Result<List<RosterStudentDto>>>;

public record RosterStudentDto(
    Guid StudentId,
    string FullName,
    string? FullNameEn,
    string Grade);
