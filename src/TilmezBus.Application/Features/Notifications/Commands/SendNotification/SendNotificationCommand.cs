using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Notifications.Commands.SendNotification;

public record SendNotificationCommand(
    string Title,
    string Message,
    NotificationType Type,
    string? RecipientId,
    Guid? RelatedTripId,
    Guid? RelatedBusId
) : IRequest<Result<Guid>>;
