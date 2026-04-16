using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Notifications.Queries.GetNotificationsByRecipient;

public record GetNotificationsByRecipientQuery(string RecipientId, int PageNumber = 1, int PageSize = 20) : IRequest<PagedResult<NotificationDto>>;

public record NotificationDto(Guid Id, string Title, string Message, NotificationType Type, bool IsRead, DateTime CreatedAt);
