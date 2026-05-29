using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Notifications.Commands.SendNotification;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Commands.ScanStudent;

public class ScanStudentCommandHandler
    : IRequestHandler<ScanStudentCommand, Result<ScanStudentResponse>>
{
    private readonly IApplicationDbContext _context;
    private readonly IMediator _mediator;
    private readonly INotificationTemplateService _templates;
    private readonly ILogger<ScanStudentCommandHandler> _logger;

    public ScanStudentCommandHandler(
        IApplicationDbContext context,
        IMediator mediator,
        INotificationTemplateService templates,
        ILogger<ScanStudentCommandHandler> logger)
    {
        _context   = context;
        _mediator  = mediator;
        _templates = templates;
        _logger    = logger;
    }

    public async Task<Result<ScanStudentResponse>> Handle(
        ScanStudentCommand request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.QrToken))
            return Result<ScanStudentResponse>.Failure("QR token is required.");

        // Trip must exist and be active.
        var trip = await _context.Trips
            .FirstOrDefaultAsync(t => t.Id == request.TripId, ct);
        if (trip is null)
            return Result<ScanStudentResponse>.Failure("Trip not found.");
        if (trip.Status == TripStatus.Completed)
            return Result<ScanStudentResponse>.Failure("Trip has already ended.");

        // Resolve the QR token to a student.
        var qr = await _context.StudentQrTokens
            .FirstOrDefaultAsync(q => q.Token == request.QrToken.Trim(), ct);
        if (qr is null || qr.StudentId is null)
            return Result<ScanStudentResponse>.Failure("Student not found for this QR.");

        var student = await _context.Students
            .FirstOrDefaultAsync(s => s.Id == qr.StudentId, ct);
        if (student is null)
            return Result<ScanStudentResponse>.Failure("Student record missing.");

        // Find or create the StudentTrip row.
        var st = await _context.StudentTrips
            .FirstOrDefaultAsync(x => x.TripId == trip.Id && x.StudentId == student.Id, ct);

        var addedToRoster = false;
        var now = DateTime.UtcNow;
        // Snapshot the previous boarding state so we don't re-fire the
        // parent push when the assistant scans the same card twice in a
        // row (or scans after a long press on the row in the UI).
        var previouslyBoarded =
            st is not null && st.BoardingStatus == BoardingStatus.Boarded;

        if (st is null)
        {
            st = new StudentTrip
            {
                TripId         = trip.Id,
                StudentId      = student.Id,
                BoardingStatus = BoardingStatus.Boarded,
                BoardingTime   = now,
            };
            _context.StudentTrips.Add(st);
            addedToRoster = true;
        }
        else
        {
            st.BoardingStatus = BoardingStatus.Boarded;
            st.BoardingTime   = now;
        }

        // Capture home GPS the first time we have it — subsequent scans
        // don't overwrite to keep the canonical home location stable.
        if (trip.Type == TripType.Morning
            && request.Latitude is double lat
            && request.Longitude is double lng
            && student.Latitude is null
            && student.Longitude is null)
        {
            student.Latitude  = lat;
            student.Longitude = lng;
        }

        await _context.SaveChangesAsync(ct);

        // Parent push: only on the Waiting → Boarded transition (or the
        // first-time addToRoster scan). Skips re-scans that don't change
        // status so a stuttery NFC tap doesn't double-banner the parent.
        // Mirrors UpdateBoardingStatusCommandHandler's behaviour for the
        // manual roster-tap path.
        var firstBoardingThisTrip = !previouslyBoarded;
        if (firstBoardingThisTrip)
        {
            await NotifyParentStudentBoardedAsync(student, trip.Id, ct);
        }

        return Result<ScanStudentResponse>.Success(new ScanStudentResponse(
            student.Id, student.FullName,
            st.BoardingStatus.ToString(), now, addedToRoster));
    }

    /// <summary>
    /// Fire-and-forget parent push using the existing StudentBoarded
    /// template (template service picks language per device). Mirrors
    /// the manual-tap path in UpdateBoardingStatusCommandHandler so the
    /// QR/NFC scan UX surfaces the same notification.
    /// </summary>
    private async Task NotifyParentStudentBoardedAsync(
        Student student, Guid tripId, CancellationToken ct)
    {
        try
        {
            var parentUserId = await _context.Students
                .Where(s => s.Id == student.Id && s.Parent != null)
                .Select(s => s.Parent!.UserId)
                .FirstOrDefaultAsync(ct);
            if (string.IsNullOrEmpty(parentUserId)) return;

            var (title, message) = await _templates.RenderAsync(
                NotificationType.StudentBoarded,
                "ar",
                new Dictionary<string, string?>
                {
                    ["studentName"] = student.FullName,
                },
                ct);
            await _mediator.Send(
                new SendNotificationCommand(
                    title, message, NotificationType.StudentBoarded,
                    parentUserId, tripId, null),
                ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex,
                "[ScanStudent] StudentBoarded push failed for student={Student} trip={Trip}",
                student.Id, tripId);
        }
    }
}
