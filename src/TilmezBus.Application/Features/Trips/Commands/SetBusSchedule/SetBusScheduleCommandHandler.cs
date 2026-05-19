using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Commands.SetBusSchedule;

public class SetBusScheduleCommandHandler : IRequestHandler<SetBusScheduleCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public SetBusScheduleCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
    }

    public async Task<Result> Handle(SetBusScheduleCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result.Failure("Bus not found.");

        if (!TimeOnly.TryParse(request.MorningTime, out var morningTime))
            return Result.Failure("Invalid morning time format. Use HH:mm.");
        if (!TimeOnly.TryParse(request.ReturnTime, out var returnTime))
            return Result.Failure("Invalid return time format. Use HH:mm.");

        if (returnTime <= morningTime)
            return Result.Failure("Return time must be after the morning time.");

        var driverIds = new[] { request.MorningDriverId, request.MorningAssistantId, request.ReturnDriverId, request.ReturnAssistantId }
            .Where(id => id is not null)
            .Select(id => id!.Value)
            .Distinct()
            .ToArray();

        if (driverIds.Length > 0)
        {
            var drivers = await _context.Drivers
                .Where(d => driverIds.Contains(d.Id) && !d.IsDeleted)
                .Select(d => new { d.Id, d.DriverType })
                .ToListAsync(cancellationToken);

            if (drivers.Count != driverIds.Length)
                return Result.Failure("One or more selected drivers/assistants were not found.");

            bool IsWrongType(Guid? id, DriverType expected)
                => id is not null && drivers.First(d => d.Id == id.Value).DriverType != expected;

            if (IsWrongType(request.MorningDriverId, DriverType.Driver) ||
                IsWrongType(request.ReturnDriverId,  DriverType.Driver))
                return Result.Failure("Selected morning/return driver must be of type Driver.");

            if (IsWrongType(request.MorningAssistantId, DriverType.Assistant) ||
                IsWrongType(request.ReturnAssistantId,  DriverType.Assistant))
                return Result.Failure("Selected morning/return assistant must be of type Assistant.");
        }

        var selectedStudentIds = request.StudentIds?.Distinct().ToHashSet() ?? new HashSet<Guid>();

        // Filter out soft-deleted / non-existent students up-front so the capacity check
        // compares apples-to-apples with what will actually be saved.
        if (selectedStudentIds.Count > 0)
        {
            var existingStudentIds = await _context.Students
                .Where(s => !s.IsDeleted && selectedStudentIds.Contains(s.Id))
                .Select(s => s.Id)
                .ToListAsync(cancellationToken);
            selectedStudentIds.IntersectWith(existingStudentIds);
        }

        if (selectedStudentIds.Count > bus.Capacity)
            return Result.Failure($"Selected students ({selectedStudentIds.Count}) exceed the bus capacity ({bus.Capacity}).");

        // Conflict check: nobody can be on two buses' non-completed trips at once.
        // "Non-completed" = Scheduled | InProgress (Completed is OK).
        var pendingStatuses = new[] { TripStatus.Scheduled, TripStatus.InProgress };

        if (selectedStudentIds.Count > 0)
        {
            var studentConflicts = await _context.StudentTrips
                .Where(st => selectedStudentIds.Contains(st.StudentId)
                             && st.Trip.BusId != request.BusId
                             && !st.Trip.IsTemplate
                             && pendingStatuses.Contains(st.Trip.Status))
                .Select(st => new { st.StudentId, st.Student.FullName, st.Trip.Bus.PlateNumber })
                .Distinct()
                .ToListAsync(cancellationToken);

            if (studentConflicts.Count > 0)
            {
                var first = studentConflicts[0];
                return Result.Failure(
                    $"Student '{first.FullName}' is already on an active trip for bus '{first.PlateNumber}'.");
            }
        }

        if (driverIds.Length > 0)
        {
            // A driver/assistant is "taken" when they're named in another bus's schedule
            // AND that other bus has at least one non-completed trip.
            var conflictingBuses = await _context.BusSchedules
                .Where(s => s.BusId != request.BusId && !s.IsDeleted)
                .Where(s => (s.MorningDriverId    != null && driverIds.Contains(s.MorningDriverId.Value)) ||
                            (s.MorningAssistantId != null && driverIds.Contains(s.MorningAssistantId.Value)) ||
                            (s.ReturnDriverId     != null && driverIds.Contains(s.ReturnDriverId.Value)) ||
                            (s.ReturnAssistantId  != null && driverIds.Contains(s.ReturnAssistantId.Value)))
                .Select(s => new
                {
                    s.BusId,
                    PlateNumber = s.Bus.PlateNumber,
                    s.MorningDriverId,
                    s.MorningAssistantId,
                    s.ReturnDriverId,
                    s.ReturnAssistantId
                })
                .ToListAsync(cancellationToken);

            if (conflictingBuses.Count > 0)
            {
                var conflictingBusIds = conflictingBuses.Select(x => x.BusId).Distinct().ToList();
                var busesWithActive = await _context.Trips
                    .Where(t => conflictingBusIds.Contains(t.BusId)
                                && !t.IsTemplate && !t.IsDeleted
                                && pendingStatuses.Contains(t.Status))
                    .Select(t => t.BusId)
                    .Distinct()
                    .ToListAsync(cancellationToken);

                var blocker = conflictingBuses.FirstOrDefault(x => busesWithActive.Contains(x.BusId));
                if (blocker is not null)
                {
                    var takenId = new[] { blocker.MorningDriverId, blocker.MorningAssistantId, blocker.ReturnDriverId, blocker.ReturnAssistantId }
                        .FirstOrDefault(id => id is not null && driverIds.Contains(id.Value));
                    var takenName = takenId is null
                        ? "Driver/assistant"
                        : (await _context.Drivers.Where(d => d.Id == takenId.Value).Select(d => d.FullName).FirstOrDefaultAsync(cancellationToken)) ?? "Driver/assistant";
                    return Result.Failure($"{takenName} is already assigned to bus '{blocker.PlateNumber}' which has active trips.");
                }
            }
        }

        var existing = await _context.BusSchedules
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(s => s.BusId == request.BusId, cancellationToken);

        BusSchedule schedule;
        if (existing is null)
        {
            schedule = new BusSchedule
            {
                BusId              = request.BusId,
                MorningTime        = morningTime,
                ReturnTime         = returnTime,
                RepeatDays         = request.RepeatDays,
                MorningDriverId    = request.MorningDriverId,
                MorningAssistantId = request.MorningAssistantId,
                ReturnDriverId     = request.ReturnDriverId,
                ReturnAssistantId  = request.ReturnAssistantId,
                StudentCount       = selectedStudentIds.Count,
                IsDeleted          = false
            };
            _context.BusSchedules.Add(schedule);
            await _context.SaveChangesAsync(cancellationToken); // assign Id for join rows
        }
        else
        {
            schedule = existing;
            schedule.MorningTime        = morningTime;
            schedule.ReturnTime         = returnTime;
            schedule.RepeatDays         = request.RepeatDays;
            schedule.MorningDriverId    = request.MorningDriverId;
            schedule.MorningAssistantId = request.MorningAssistantId;
            schedule.ReturnDriverId     = request.ReturnDriverId;
            schedule.ReturnAssistantId  = request.ReturnAssistantId;
            schedule.IsDeleted          = false;
        }

        var currentJoin = await _context.BusScheduleStudents
            .Where(x => x.BusScheduleId == schedule.Id)
            .ToListAsync(cancellationToken);

        var toRemove = currentJoin.Where(x => !selectedStudentIds.Contains(x.StudentId)).ToList();
        if (toRemove.Count > 0) _context.BusScheduleStudents.RemoveRange(toRemove);

        var currentIds = currentJoin.Select(x => x.StudentId).ToHashSet();
        foreach (var studentId in selectedStudentIds)
        {
            if (!currentIds.Contains(studentId))
            {
                _context.BusScheduleStudents.Add(new BusScheduleStudent
                {
                    BusScheduleId = schedule.Id,
                    StudentId     = studentId
                });
            }
        }

        schedule.StudentCount = selectedStudentIds.Count;

        var today = DateTime.UtcNow.Date;

        // If today's weekday is in RepeatDays and a Morning/Return trip isn't yet generated,
        // create it now so the schedule change is reflected immediately (instead of waiting
        // for the midnight Hangfire job). Skip per-direction if driver/assistant/students
        // aren't fully assigned — an incomplete schedule shouldn't produce trips.
        var todayBit = (byte)(1 << (int)today.DayOfWeek);
        var hasStudents          = selectedStudentIds.Count > 0;
        var canCreateMorningTrip = hasStudents && request.MorningDriverId is not null && request.MorningAssistantId is not null;
        var canCreateReturnTrip  = hasStudents && request.ReturnDriverId  is not null && request.ReturnAssistantId  is not null;

        if ((schedule.RepeatDays & todayBit) != 0 && (canCreateMorningTrip || canCreateReturnTrip))
        {
            var existingTodayTypes = (await _context.Trips
                .Where(t => !t.IsTemplate
                            && t.BusId == request.BusId
                            && t.ScheduledDeparture >= today
                            && t.ScheduledDeparture < today.AddDays(1))
                .Select(t => t.Type)
                .ToListAsync(cancellationToken))
                .ToHashSet();

            bool addedTrip = false;
            if (canCreateMorningTrip && !existingTodayTypes.Contains(TripType.Morning))
            {
                _context.Trips.Add(new Trip
                {
                    BusId              = request.BusId,
                    Type               = TripType.Morning,
                    Name               = $"{bus.PlateNumber} — ذهاب — {today:dd/MM/yyyy}",
                    ScheduledDeparture = today.Add(morningTime.ToTimeSpan()),
                    RepeatDays         = 0,
                    Status             = TripStatus.Scheduled,
                    IsTemplate         = false
                });
                addedTrip = true;
            }
            if (canCreateReturnTrip && !existingTodayTypes.Contains(TripType.Return))
            {
                _context.Trips.Add(new Trip
                {
                    BusId              = request.BusId,
                    Type               = TripType.Return,
                    Name               = $"{bus.PlateNumber} — إياب — {today:dd/MM/yyyy}",
                    ScheduledDeparture = today.Add(returnTime.ToTimeSpan()),
                    RepeatDays         = 0,
                    Status             = TripStatus.Scheduled,
                    IsTemplate         = false
                });
                addedTrip = true;
            }
            if (addedTrip) await _context.SaveChangesAsync(cancellationToken); // assign Trip.Id before roster sync
        }

        // Propagate to already-generated trips that haven't started yet:
        //   • shift ScheduledDeparture to match the new per-direction time
        //   • sync StudentTrip roster to match the selected students
        // Only trips with Status == Scheduled (not InProgress/Completed) are touched,
        // and only today-or-future ones (past days stay frozen for historical accuracy).
        var pendingTrips = await _context.Trips
            .Where(t => !t.IsTemplate
                        && t.BusId == request.BusId
                        && t.Status == TripStatus.Scheduled
                        && t.ScheduledDeparture >= today)
            .ToListAsync(cancellationToken);

        foreach (var trip in pendingTrips)
        {
            var day = trip.ScheduledDeparture.Date;
            trip.ScheduledDeparture = trip.Type == TripType.Morning
                ? day.Add(morningTime.ToTimeSpan())
                : day.Add(returnTime.ToTimeSpan());
        }

        if (pendingTrips.Count > 0)
        {
            var pendingTripIds = pendingTrips.Select(t => t.Id).ToList();
            var existingStudentTrips = await _context.StudentTrips
                .Where(st => pendingTripIds.Contains(st.TripId))
                .ToListAsync(cancellationToken);

            // Drop rows for students no longer on the schedule.
            var stale = existingStudentTrips.Where(st => !selectedStudentIds.Contains(st.StudentId)).ToList();
            if (stale.Count > 0) _context.StudentTrips.RemoveRange(stale);

            // Add rows for newly-added students on each pending trip (skip duplicates).
            var existingKeys = existingStudentTrips.Select(st => (st.TripId, st.StudentId)).ToHashSet();
            foreach (var trip in pendingTrips)
            {
                foreach (var studentId in selectedStudentIds)
                {
                    if (existingKeys.Contains((trip.Id, studentId))) continue;
                    _context.StudentTrips.Add(new StudentTrip
                    {
                        TripId         = trip.Id,
                        StudentId      = studentId,
                        BoardingStatus = BoardingStatus.Waiting
                    });
                }
            }
        }

        await _context.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
