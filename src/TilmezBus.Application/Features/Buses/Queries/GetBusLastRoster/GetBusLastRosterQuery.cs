using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Buses.Queries.GetBusLastRoster;

/// <summary>
/// Roster (students) of the most recent trip on this (BusId, TripType).
/// Used by the assistant trip-setup screen to pre-fill the student list
/// so the assistant doesn't have to re-pick the same kids every leg.
/// Empty list when no prior trip exists.
/// </summary>
public record GetBusLastRosterQuery(Guid BusId, TripType TripType)
    : IRequest<Result<List<RosterStudentDto>>>;

public record RosterStudentDto(
    Guid StudentId,
    string FullName,
    string? FullNameEn,
    string Grade);
