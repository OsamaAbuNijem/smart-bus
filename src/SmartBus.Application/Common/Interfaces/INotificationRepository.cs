using SmartBus.Domain.Entities;

namespace SmartBus.Application.Common.Interfaces;

public interface INotificationRepository : IGenericRepository<Notification>
{
    Task<IReadOnlyList<Notification>> GetByRecipientAsync(string recipientId, CancellationToken cancellationToken = default);
    Task MarkAsReadAsync(Guid notificationId, CancellationToken cancellationToken = default);
}
