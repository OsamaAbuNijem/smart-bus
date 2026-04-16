using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Commands.UpdateTripStatus;

public class UpdateTripStatusCommandHandler : IRequestHandler<UpdateTripStatusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ISignalRNotificationService _notificationService;

    public UpdateTripStatusCommandHandler(IUnitOfWork unitOfWork, ISignalRNotificationService notificationService)
    {
        _unitOfWork = unitOfWork;
        _notificationService = notificationService;
    }

    public async Task<Result> Handle(UpdateTripStatusCommand request, CancellationToken cancellationToken)
    {
        var trip = await _unitOfWork.Trips.GetByIdAsync(request.TripId, cancellationToken);
        if (trip is null) return Result.Failure("Trip not found.");

        switch (request.NewStatus)
        {
            case TripStatus.InProgress: trip.Start(); break;
            case TripStatus.Completed: trip.Complete(); break;
            case TripStatus.Cancelled: trip.Cancel(request.Notes); break;
            default: return Result.Failure("Invalid status transition.");
        }

        await _unitOfWork.Trips.UpdateAsync(trip);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _notificationService.SendTripStatusUpdateAsync(trip.Id, request.NewStatus.ToString(), cancellationToken);

        return Result.Success();
    }
}
