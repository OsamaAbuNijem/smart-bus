using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Trips.Queries.GetBusSchedule;

public record GetBusScheduleQuery(Guid BusId) : IRequest<Result<BusScheduleDto>>;

public record BusScheduleDto(
    string? MorningTime,
    string? ReturnTime,
    byte RepeatDays,
    Guid? MorningDriverId,
    Guid? MorningAssistantId,
    Guid? ReturnDriverId,
    Guid? ReturnAssistantId,
    IReadOnlyList<Guid> StudentIds
);
