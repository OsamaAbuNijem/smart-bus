using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Trips.Queries.GetAllBusSchedules;

public record GetAllBusSchedulesQuery(Guid? SchoolId = null) : IRequest<Result<List<BusScheduleSummaryDto>>>;

/// <summary>Minimal schedule info per bus — used by the buses grid to show schedule status.</summary>
public record BusScheduleSummaryDto(
    Guid   BusId,
    string MorningTime,
    string ReturnTime,
    byte   RepeatDays
);
