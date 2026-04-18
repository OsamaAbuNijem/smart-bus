using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.SetBusSchedule;

/// <summary>
/// Creates or replaces the two recurring trips (Morning = ذهاب, Return = إياب) for a bus.
/// </summary>
public record SetBusScheduleCommand(
    Guid BusId,
    string MorningTime,   // "HH:mm"
    string ReturnTime,    // "HH:mm"
    byte RepeatDays       // bitmask: 1=Sun,2=Mon,4=Tue,8=Wed,16=Thu,32=Fri,64=Sat
) : IRequest<Result>;
