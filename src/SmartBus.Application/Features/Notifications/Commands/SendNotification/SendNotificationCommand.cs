using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Notifications.Commands.SendNotification;

public record SendNotificationCommand(
    string Title,
    string Message,
    NotificationType Type,
    string? RecipientId,
    Guid? RelatedTripId,
    Guid? RelatedBusId
) : IRequest<Result<Guid>>;
