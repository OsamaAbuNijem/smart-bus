using MediatR;
using Microsoft.Extensions.Logging;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Notifications.Commands.SendNotification;

public class SendNotificationCommandHandler : IRequestHandler<SendNotificationCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ISignalRNotificationService _signalRService;
    private readonly IPushNotificationService _push;
    private readonly ILogger<SendNotificationCommandHandler> _logger;

    public SendNotificationCommandHandler(
        IUnitOfWork unitOfWork,
        ISignalRNotificationService signalRService,
        IPushNotificationService push,
        ILogger<SendNotificationCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _signalRService = signalRService;
        _push = push;
        _logger = logger;
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
        {
            await _signalRService.SendNotificationToUserAsync(request.RecipientId, request.Title, request.Message, cancellationToken);

            // Without this, in-app SignalR is the only push surface — a
            // backgrounded / locked phone won't see a banner. SendFcmOnly
            // skips re-inserting the inbox row (we already wrote it
            // above with the Related* fields the FCM path can't carry).
            try
            {
                var data = new Dictionary<string, string>
                {
                    ["type"] = request.Type.ToString(),
                };
                if (request.RelatedTripId is Guid tripId)
                    data["tripId"] = tripId.ToString();
                if (request.RelatedBusId is Guid busId)
                    data["busId"] = busId.ToString();

                await _push.SendFcmOnlyToUserAsync(
                    request.RecipientId,
                    request.Title,
                    request.Message,
                    data,
                    cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex,
                    "[SendNotification] FCM hop failed for recipient {Recipient} type {Type}",
                    request.RecipientId, request.Type);
            }
        }
        else
        {
            await _signalRService.SendNotificationToAllAsync(request.Title, request.Message, cancellationToken);
        }

        return Result<Guid>.Success(notification.Id);
    }
}
