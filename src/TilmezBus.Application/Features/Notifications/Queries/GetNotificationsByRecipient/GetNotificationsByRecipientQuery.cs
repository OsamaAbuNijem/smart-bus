using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Notifications.Queries.GetNotificationsByRecipient;

public record GetNotificationsByRecipientQuery(string RecipientId, int PageNumber = 1, int PageSize = 20) : IRequest<PagedResult<NotificationDto>>;

public record NotificationDto(Guid Id, string Title, string Message, NotificationType Type, bool IsRead, DateTime CreatedAt);
