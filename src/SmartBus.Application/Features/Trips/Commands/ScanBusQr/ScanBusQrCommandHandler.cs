using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Commands.ScanBusQr;

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

        // 2. Scanner identity. JWT email is `<digits>@smartbus.local`; recover the phone.
        var email = _currentUser.UserName;
        if (string.IsNullOrEmpty(email))
            return Result<ScanBusQrResponse>.Failure("Unauthenticated.");

        var phone = email.Split('@')[0];
        var driver = await _unitOfWork.Drivers.GetByPhoneNumberAsync(phone, ct);
        if (driver is null)
            return Result<ScanBusQrResponse>.Failure("The scanning user is not registered as a driver/assistant.");

        // 3. Bus schedule + slot matching.
        var schedule = await _context.BusSchedules
            .FirstOrDefaultAsync(s => s.BusId == bus.Id, ct);
        if (schedule is null)
            return Result<ScanBusQrResponse>.Failure("This bus has no schedule configured. Ask the admin to set one.");

        var inMorning = driver.Id == schedule.MorningDriverId || driver.Id == schedule.MorningAssistantId;
        var inReturn  = driver.Id == schedule.ReturnDriverId  || driver.Id == schedule.ReturnAssistantId;

        if (!inMorning && !inReturn)
            return Result<ScanBusQrResponse>.Failure("You are not assigned to this bus.");

        TripType tripType;
        if (inMorning && inReturn)
            tripType = DateTime.UtcNow.Hour < 12 ? TripType.Morning : TripType.Return;
        else
            tripType = inMorning ? TripType.Morning : TripType.Return;

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
        var departure = tripType == TripType.Morning
            ? today.Add(schedule.MorningTime.ToTimeSpan())
            : today.Add(schedule.ReturnTime.ToTimeSpan());
        // If the schedule's nominal time already passed for this leg, anchor to "now" instead
        // so the trip's ScheduledDeparture sorts correctly in today's lists.
        if (departure < now) departure = now;

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
        await _unitOfWork.Trips.AddAsync(trip, ct);
        await _unitOfWork.SaveChangesAsync(ct); // assign Trip.Id before roster rows

        // 5b. Roster — copy the schedule's students into StudentTrip rows.
        var studentIds = await _context.BusScheduleStudents
            .Where(x => x.BusScheduleId == schedule.Id)
            .Select(x => x.StudentId)
            .ToListAsync(ct);

        foreach (var studentId in studentIds)
        {
            _context.StudentTrips.Add(new StudentTrip
            {
                TripId         = trip.Id,
                StudentId      = studentId,
                BoardingStatus = BoardingStatus.Waiting
            });
        }
        if (studentIds.Count > 0)
            await _context.SaveChangesAsync(ct);

        _logger.LogInformation(
            "[ScanQR] Bus={BusId} Driver={DriverId} Type={TripType} → Trip {TripId} created",
            bus.Id, driver.Id, tripType, trip.Id);

        return Result<ScanBusQrResponse>.Success(
            new ScanBusQrResponse(trip.Id, bus.Id, bus.PlateNumber, tripType.ToString(), AlreadyExisted: false));
    }
}
