using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Notifications.Commands.MarkNotificationAsRead;

public record MarkNotificationAsReadCommand(Guid NotificationId) : IRequest<Result>;
