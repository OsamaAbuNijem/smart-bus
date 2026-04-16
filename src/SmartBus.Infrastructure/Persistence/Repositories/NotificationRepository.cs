using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Domain.Entities;

namespace SmartBus.Infrastructure.Persistence.Repositories;

public class NotificationRepository : GenericRepository<Notification>, INotificationRepository
{
    public NotificationRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IReadOnlyList<Notification>> GetByRecipientAsync(string recipientId, CancellationToken cancellationToken = default)
        => await _dbSet.Where(n => n.RecipientId == recipientId)
            .OrderByDescending(n => n.CreatedAt).ToListAsync(cancellationToken);

    public async Task MarkAsReadAsync(Guid notificationId, CancellationToken cancellationToken = default)
    {
        var notification = await _dbSet.FindAsync(new object[] { notificationId }, cancellationToken);
        if (notification is not null)
        {
            notification.IsRead = true;
            notification.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
}
