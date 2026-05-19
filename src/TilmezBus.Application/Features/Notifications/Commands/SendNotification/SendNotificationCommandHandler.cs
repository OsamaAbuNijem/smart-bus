using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Notifications.Commands.SendNotification;

public class SendNotificationCommandHandler : IRequestHandler<SendNotificationCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ISignalRNotificationService _signalRService;

    public SendNotificationCommandHandler(IUnitOfWork unitOfWork, ISignalRNotificationService signalRService)
    {
        _unitOfWork = unitOfWork;
        _signalRService = signalRService;
    }

    public async Task<Result<Guid>> Handle(SendNotificationCommand request, CancellationToken cancellationToken)
    {
        var notification = new Notification
        {
            Title = request.Title,
            Message = request.Message,
            Type = request.Type,
            RecipientId = request.RecipientId,
            RelatedTripId = request.RelatedTripId,
            RelatedBusId = request.RelatedBusId
        };

        await _unitOfWork.Notifications.AddAsync(notification, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        if (request.RecipientId is not null)
            await _signalRService.SendNotificationToUserAsync(request.RecipientId, request.Title, request.Message, cancellationToken);
        else
            await _signalRService.SendNotificationToAllAsync(request.Title, request.Message, cancellationToken);

        return Result<Guid>.Success(notification.Id);
    }
}
