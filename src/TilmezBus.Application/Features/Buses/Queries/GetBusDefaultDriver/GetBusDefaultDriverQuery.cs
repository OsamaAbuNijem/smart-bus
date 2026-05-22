using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Buses.Queries.GetBusDefaultDriver;

/// <summary>
/// Driver from the most recent Trip on (BusId, TripType). Used by the
/// assistant trip-setup screen to pre-fill the driver picker so the same
/// driver who ran the previous leg is selected by default. Returns null
/// when this bus + trip type has no prior trip.
/// </summary>
public record GetBusDefaultDriverQuery(Guid BusId, TripType TripType)
    : IRequest<Result<DefaultDriverDto?>>;

public record DefaultDriverDto(
    Guid Id,
    string FullName,
    string PhoneNumber,
    string DriverType);
