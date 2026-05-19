using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Notifications.Commands.SendNotification;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Students.Commands.ScanQr;

public class ScanStudentQrCommandHandler
    : IRequestHandler<ScanStudentQrCommand, Result<ScanStudentQrResponse>>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogger<ScanStudentQrCommandHandler> _logger;
    private readonly IMediator _mediator;
    private readonly INotificationTemplateService _templates;

    public ScanStudentQrCommandHandler(
        IApplicationDbContext context,
        ILogger<ScanStudentQrCommandHandler> logger,
        IMediator mediator,
        INotificationTemplateService templates)
    {
        _context   = context;
        _logger    = logger;
        _mediator  = mediator;
        _templates = templates;
    }

    public async Task<Result<ScanStudentQrResponse>> Handle(ScanStudentQrCommand request, CancellationToken ct)
    {
        var token = (request.Token ?? string.Empty).Trim();
        if (token.Length == 0) return Fail("QR token is required.");
        if (request.TripId == Guid.Empty) return Fail("Trip id is required.");

        // 1. Resolve token → student
        var qr = await _context.StudentQrTokens
            .FirstOrDefaultAsync(t => t.Token == token, ct);
        if (qr is null)             return Fail("Student QR not found.");
        if (!qr.IsRegistered ||
            qr.StudentId is null)   return Fail("This QR has not been linked to a student yet — the parent must register the student first.");

        // 2. Resolve trip + ensure it's the active one
        var trip = await _context.Trips
            .FirstOrDefaultAsync(t => t.Id == request.TripId && !t.IsTemplate, ct);
        if (trip is null)                                return Fail("Trip not found.");
        if (trip.Status == TripStatus.Completed)         return Fail("This trip is already completed.");

        // 3. Find or create the StudentTrip row for (trip, student)
        var studentTrip = await _context.StudentTrips
            .FirstOrDefaultAsync(st => st.TripId == trip.Id && st.StudentId == qr.StudentId, ct);
        if (studentTrip is null)
        {
            // Late-add: the schedule may not have included this student yet,
            // but the QR proves they're on the bus. Create the row on the fly.
            studentTrip = new StudentTrip
            {
                TripId         = trip.Id,
                StudentId      = qr.StudentId.Value,
                BoardingStatus = BoardingStatus.Waiting
            };
            _context.StudentTrips.Add(studentTrip);
            await _context.SaveChangesAsync(ct);
        }

        var now = DateTime.UtcNow;
        string action;

        // 4. State machine
        if (studentTrip.BoardingStatus == BoardingStatus.Waiting
            || studentTrip.BoardingStatus == BoardingStatus.Absent)
        {
            // First scan → board
            studentTrip.BoardingStatus = BoardingStatus.Boarded;
            studentTrip.BoardingTime   = now;
            action = "Boarded";

            await UpsertAttendanceAsync(qr.StudentId.Value, trip.Id, now, dropoff: null, ct);
        }
        else // Boarded
        {
            if (studentTrip.DropoffTime is null)
            {
                // Second scan → dropoff (got off the bus)
                studentTrip.DropoffTime = now;
                action = "Dropoff";

                await UpsertAttendanceAsync(qr.StudentId.Value, trip.Id, studentTrip.BoardingTime, dropoff: now, ct);
            }
            else
            {
                // Third+ scan after dropoff: no-op
                action = "AlreadyDroppedOff";
            }
        }

        await _context.SaveChangesAsync(ct);

        // 5. Pull the student name + parent for the response and any
        //    pickup / drop-off push that needs to fire.
        var studentInfo = await _context.Students
            .Where(s => s.Id == qr.StudentId.Value)
            .Select(s => new
            {
                s.FullName,
                ParentUserId = s.Parent != null ? s.Parent.UserId : null,
            })
            .FirstOrDefaultAsync(ct);
        var studentName = studentInfo?.FullName ?? string.Empty;

        // Parent push — Morning trips trigger on first board, Return trips
        // on first drop-off. The state machine above only flips action to
        // those values on the meaningful transition, so we won't double-fire.
        var notify =
            (trip.Type == TripType.Morning && action == "Boarded") ||
            (trip.Type == TripType.Return  && action == "Dropoff");
        if (notify && studentInfo?.ParentUserId is not null)
        {
            var type = action == "Boarded"
                ? NotificationType.StudentBoarded
                : NotificationType.StudentArrived;
            var (title, message) = await _templates.RenderAsync(
                type,
                "ar",
                new Dictionary<string, string?>
                {
                    ["studentName"] = studentName,
                },
                ct);

            await _mediator.Send(
                new SendNotificationCommand(
                    title, message, type,
                    studentInfo.ParentUserId, trip.Id, null),
                ct);
        }

        _logger.LogInformation(
            "[StudentQrScan] Trip={TripId} Student={StudentId} → {Action}",
            trip.Id, qr.StudentId, action);

        return Result<ScanStudentQrResponse>.Success(
            new ScanStudentQrResponse(
                qr.StudentId.Value, studentName, trip.Id, action,
                studentTrip.BoardingStatus.ToString(),
                studentTrip.BoardingTime, studentTrip.DropoffTime));
    }

    /// <summary>
    /// Today's daily attendance record for (student, trip). Created on first
    /// scan; the second scan only updates DropoffTime.
    /// </summary>
    private async Task UpsertAttendanceAsync(
        Guid studentId, Guid tripId, DateTime? boarding, DateTime? dropoff, CancellationToken ct)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var att = await _context.Attendances
            .FirstOrDefaultAsync(a => a.StudentId == studentId && a.TripId == tripId && a.Date == today, ct);

        if (att is null)
        {
            att = new TilmezBus.Domain.Entities.Attendance
            {
                StudentId    = studentId,
                TripId       = tripId,
                Date         = today,
                Status       = AttendanceStatus.Present,
                BoardingTime = boarding,
                DropoffTime  = dropoff
            };
            _context.Attendances.Add(att);
        }
        else
        {
            if (boarding is not null) att.BoardingTime = boarding;
            if (dropoff  is not null) att.DropoffTime  = dropoff;
            att.Status = AttendanceStatus.Present;
        }
    }

    private static Result<ScanStudentQrResponse> Fail(string message)
        => Result<ScanStudentQrResponse>.Failure(message);
}
