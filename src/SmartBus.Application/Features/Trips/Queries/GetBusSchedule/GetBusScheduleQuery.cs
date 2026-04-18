using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Queries.GetBusSchedule;

public record GetBusScheduleQuery(Guid BusId) : IRequest<Result<BusScheduleDto>>;

public record BusScheduleDto(
    string? MorningTime,   // "HH:mm" or null if not set
    string? ReturnTime,    // "HH:mm" or null if not set
    byte RepeatDays
);
