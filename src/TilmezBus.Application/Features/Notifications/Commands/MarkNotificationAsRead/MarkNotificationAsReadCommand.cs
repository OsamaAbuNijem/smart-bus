using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Notifications.Commands.MarkNotificationAsRead;

public record MarkNotificationAsReadCommand(Guid NotificationId) : IRequest<Result>;
