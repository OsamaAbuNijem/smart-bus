using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.ScanBusQr;

/// <summary>
/// Mobile-app entry point for starting a trip on demand.
/// Sent by a logged-in driver/assistant after scanning a bus's QR sticker.
/// </summary>
public record ScanBusQrCommand(string QrToken) : IRequest<Result<ScanBusQrResponse>>, ICacheInvalidator
{
    // Touching trips invalidates the cached page lists.
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "trips:page:*" };
}

public record ScanBusQrResponse(
    Guid TripId,
    Guid BusId,
    string PlateNumber,
    string TripType,
    bool AlreadyExisted
);
