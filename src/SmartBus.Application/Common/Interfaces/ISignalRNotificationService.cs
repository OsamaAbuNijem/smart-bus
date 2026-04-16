namespace SmartBus.Application.Common.Interfaces;

public interface ISignalRNotificationService
{
    Task SendBusLocationUpdateAsync(Guid busId, double latitude, double longitude, double? speed, CancellationToken cancellationToken = default);
    Task SendTripStatusUpdateAsync(Guid tripId, string status, CancellationToken cancellationToken = default);
    Task SendNotificationToUserAsync(string userId, string title, string message, CancellationToken cancellationToken = default);
    Task SendNotificationToAllAsync(string title, string message, CancellationToken cancellationToken = default);
}
