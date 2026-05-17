using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Commands.UpdateTripStatus;

public class UpdateTripStatusCommandHandler : IRequestHandler<UpdateTripStatusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly ISignalRNotificationService _notificationService;
    private readonly ILogger<UpdateTripStatusCommandHandler> _logger;

    public UpdateTripStatusCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        ISignalRNotificationService notificationService,
        ILogger<UpdateTripStatusCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _context = context;
        _notificationService = notificationService;
        _logger = logger;
    }

    public async Task<Result> Handle(UpdateTripStatusCommand request, CancellationToken cancellationToken)
    {
        var trip = await _unitOfWork.Trips.GetByIdAsync(request.TripId, cancellationToken);
        if (trip is null) return Result.Failure("Trip not found.");

        var fromStatus = trip.Status;
        switch (request.NewStatus)
        {
            case TripStatus.InProgress: trip.Start(); break;
            case TripStatus.Completed: trip.Complete(); break;
            default: return Result.Failure("Invalid status transition.");
        }

        await _unitOfWork.Trips.UpdateAsync(trip);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // Scheduled → InProgress on a Return trip: students were left Waiting
        // when the trip was scheduled (the assistant hadn't picked them up
        // yet). Flip them all to Boarded with the live boarding time so the
        // recap reflects who actually started the journey.
        if (fromStatus == TripStatus.Scheduled
            && request.NewStatus == TripStatus.InProgress
            && trip.Type == TripType.Return)
        {
            var now = DateTime.UtcNow;
            var waiting = await _context.StudentTrips
                .Where(st => st.TripId == trip.Id
                             && st.BoardingStatus == BoardingStatus.Waiting)
                .ToListAsync(cancellationToken);
            foreach (var st in waiting)
            {
                st.BoardingStatus = BoardingStatus.Boarded;
                st.BoardingTime  = now;
            }
            if (waiting.Count > 0)
                await _context.SaveChangesAsync(cancellationToken);
        }

        // Morning trips end at the school, so completing the trip is the
        // same event as "all boarded students have arrived". Flip them to
        // DroppedOff so the recap reflects who actually made it.
        if (request.NewStatus == TripStatus.Completed && trip.Type == TripType.Morning)
        {
            var now = DateTime.UtcNow;
            var boarded = await _context.StudentTrips
                .Where(st => st.TripId == trip.Id
                             && st.BoardingStatus == BoardingStatus.Boarded)
                .ToListAsync(cancellationToken);
            foreach (var st in boarded)
            {
                st.BoardingStatus = BoardingStatus.DroppedOff;
                st.DropoffTime ??= now;
            }
            if (boarded.Count > 0)
                await _context.SaveChangesAsync(cancellationToken);
        }

        // SignalR broadcasts are best-effort — a hub failure must not roll back a persisted status change.
        try
        {
            await _notificationService.SendTripStatusUpdateAsync(trip.Id, request.NewStatus.ToString(), cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "TripStatusUpdated broadcast failed for {TripId} → {Status}", trip.Id, request.NewStatus);
        }

        return Result.Success();
    }
}
