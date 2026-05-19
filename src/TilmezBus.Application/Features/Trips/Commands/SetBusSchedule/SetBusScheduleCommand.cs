using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Trips.Commands.SetBusSchedule;

/// <summary>
/// Creates or replaces the two recurring trips (Morning = ذهاب, Return = إياب) for a bus,
/// plus the assigned driver/assistant per direction and the student roster on the bus.
/// </summary>
public record SetBusScheduleCommand(
    Guid BusId,
    string MorningTime,
    string ReturnTime,
    byte RepeatDays,
    Guid? MorningDriverId,
    Guid? MorningAssistantId,
    Guid? ReturnDriverId,
    Guid? ReturnAssistantId,
    IReadOnlyList<Guid> StudentIds
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "trips:page:*", "buses:page:*", "students:page:*" };
}
