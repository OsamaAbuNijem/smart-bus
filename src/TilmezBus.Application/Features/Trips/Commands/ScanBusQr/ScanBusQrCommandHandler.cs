using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Commands.ScanBusQr;

/// <summary>
/// When a driver/assistant scans a bus QR from the mobile app:
///   1. Locate the bus by its opaque QrToken.
///   2. Identify the scanner from the JWT phone (looks them up in Drivers).
///   3. Match the scanner against the bus's <see cref="BusSchedule"/>:
///        • Matches Morning slot  → Morning trip
///        • Matches Return  slot  → Return  trip
///        • Matches both          → time-of-day disambiguation (before 12:00 = Morning, otherwise Return)
///   4. Idempotent: if a non-completed trip already exists today for this
///      (bus, type), return its id instead of creating a duplicate.
///   5. Otherwise create a fresh Trip with Status = InProgress and copy
///      the schedule's students into <see cref="StudentTrip"/> rows.
/// </summary>
public class ScanBusQrCommandHandler : IRequestHandler<ScanBusQrCommand, Result<ScanBusQrResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly ILogger<ScanBusQrCommandHandler> _logger;

    public ScanBusQrCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        ICurrentUserService currentUser,
        ILogger<ScanBusQrCommandHandler> logger)
    {
        _unitOfWork  = unitOfWork;
        _context     = context;
        _currentUser = currentUser;
        _logger      = logger;
    }

    public async Task<Result<ScanBusQrResponse>> Handle(ScanBusQrCommand request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.QrToken))
            return Result<ScanBusQrResponse>.Failure("QR token is required.");

        // 1. Bus from token.
        var bus = await _unitOfWork.Buses.GetByQrTokenAsync(request.QrToken.Trim(), ct);
        if (bus is null)
            return Result<ScanBusQrResponse>.Failure("Bus not found for the scanned QR.");

        // 2. Scanner identity from JWT. OTP login stores the Identity user-id
        //    on the Drivers row, so we resolve via UserId (not phone).
        var userId = _currentUser.UserId;
        if (string.IsNullOrEmpty(userId))
            return Result<ScanBusQrResponse>.Failure("Unauthenticated.");

        var driver = await _context.Drivers
            .FirstOrDefaultAsync(d => d.UserId == userId, ct);
        if (driver is null)
            return Result<ScanBusQrResponse>.Failure("The scanning user is not registered as a driver/assistant.");

        // 3. Trip type purely by clock — BusSchedule (which used to slot
        //    drivers into Morning vs Return) is gone. Anyone with a valid
        //    Drivers row for the same school can start either leg.
        var tripType = DateTime.UtcNow.Hour < 12 ? TripType.Morning : TripType.Return;

        // 4. Idempotency: re-scanning today should return the existing trip,
        //    not create a duplicate. "Today" is the UTC calendar day for parity
        //    with the rest of the trip pipeline.
        var today = DateTime.UtcNow.Date;
        var existing = await _context.Trips
            .Where(t => !t.IsTemplate
                        && t.BusId == bus.Id
                        && t.Type == tripType
                        && t.Status != TripStatus.Completed
                        && t.ScheduledDeparture >= today
                        && t.ScheduledDeparture < today.AddDays(1))
            .FirstOrDefaultAsync(ct);

        if (existing is not null)
        {
            return Result<ScanBusQrResponse>.Success(
                new ScanBusQrResponse(existing.Id, bus.Id, bus.PlateNumber, tripType.ToString(), AlreadyExisted: true));
        }

        // 5. Create the trip — already InProgress because scanning *is* the start.
        var now       = DateTime.UtcNow;
        var departure = now;

        var typeLabel = tripType == TripType.Morning ? "ذهاب" : "إياب";
        var trip = new Trip
        {
            BusId              = bus.Id,
            Type               = tripType,
            Name               = $"{bus.PlateNumber} — {typeLabel} — {today:dd/MM/yyyy}",
            ScheduledDeparture = departure,
            ActualDeparture    = now,
            Status             = TripStatus.InProgress,
            RepeatDays         = 0,
            IsTemplate         = false
        };
        // The trip starts with an empty roster — the assistant adds
        // students in the trip-setup screen before driving.
        await _unitOfWork.Trips.AddAsync(trip, ct);
        await _unitOfWork.SaveChangesAsync(ct);

        _logger.LogInformation(
            "[ScanQR] Bus={BusId} Driver={DriverId} Type={TripType} → Trip {TripId} created",
            bus.Id, driver.Id, tripType, trip.Id);

        return Result<ScanBusQrResponse>.Success(
            new ScanBusQrResponse(trip.Id, bus.Id, bus.PlateNumber, tripType.ToString(), AlreadyExisted: false));
    }
}
