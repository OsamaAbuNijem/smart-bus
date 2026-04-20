using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.SetBusSchedule;

/// <summary>
/// Creates or replaces the two recurring trips (Morning = ذهاب, Return = إياب) for a bus.
/// </summary>
public record SetBusScheduleCommand(
    Guid BusId,
    string MorningTime,
    string ReturnTime,
    byte RepeatDays
) : IRequest<Result>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "trips:page:*" };
}
