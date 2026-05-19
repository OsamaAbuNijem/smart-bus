using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Notifications.Queries.GetNotificationsByRecipient;

public class GetNotificationsByRecipientQueryHandler : IRequestHandler<GetNotificationsByRecipientQuery, PagedResult<NotificationDto>>
{
    private readonly IApplicationDbContext _context;

    public GetNotificationsByRecipientQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<NotificationDto>> Handle(GetNotificationsByRecipientQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Notifications
            .Where(n => n.RecipientId == request.RecipientId && !n.IsDeleted);

        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderByDescending(n => n.CreatedAt)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(n => new NotificationDto(n.Id, n.Title, n.Message, n.Type, n.IsRead, n.CreatedAt))
            .ToListAsync(cancellationToken);

        return PagedResult<NotificationDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
