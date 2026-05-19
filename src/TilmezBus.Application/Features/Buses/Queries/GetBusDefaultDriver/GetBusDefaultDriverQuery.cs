using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Buses.Queries.GetBusDefaultDriver;

/// <summary>
/// Default driver for a bus + trip type, taken from the bus schedule's
/// MorningDriver / ReturnDriver assignment. Used by the assistant trip-setup
/// screen to pre-fill the driver picker once a bus is selected so the
/// assistant doesn't have to choose from the full list every time.
/// </summary>
public record GetBusDefaultDriverQuery(Guid BusId, TripType TripType)
    : IRequest<Result<DefaultDriverDto?>>;

public record DefaultDriverDto(
    Guid Id,
    string FullName,
    string PhoneNumber,
    string DriverType);
