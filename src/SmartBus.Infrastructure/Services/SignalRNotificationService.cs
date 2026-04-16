using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using SmartBus.Application.Common.Interfaces;

namespace SmartBus.Infrastructure.Services;

// Hub marker interface used for DI wiring from API layer
public interface IBusTrackingHubMarker { }

public class SignalRNotificationService : ISignalRNotificationService
{
    private readonly IHubContext<Hub<IBusTrackingHubMarker>> _hubContext;
    private readonly ILogger<SignalRNotificationService> _logger;

    public SignalRNotificationService(
        IHubContext<Hub<IBusTrackingHubMarker>> hubContext,
        ILogger<SignalRNotificationService> logger)
    {
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task SendBusLocationUpdateAsync(Guid busId, double latitude, double longitude, double? speed, CancellationToken cancellationToken = default)
    {
        await _hubContext.Clients.Group($"bus-{busId}").SendAsync("BusLocationUpdated", new
        {
            BusId = busId,
            Latitude = latitude,
            Longitude = longitude,
            Speed = speed,
            Timestamp = DateTime.UtcNow
        }, cancellationToken);

        _logger.LogDebug("Sent location update for bus {BusId}: {Lat},{Lng}", busId, latitude, longitude);
    }

    public async Task SendTripStatusUpdateAsync(Guid tripId, string status, CancellationToken cancellationToken = default)
    {
        await _hubContext.Clients.All.SendAsync("TripStatusUpdated", new
        {
            TripId = tripId,
            Status = status,
            Timestamp = DateTime.UtcNow
        }, cancellationToken);
    }

    public async Task SendNotificationToUserAsync(string userId, string title, string message, CancellationToken cancellationToken = default)
    {
        await _hubContext.Clients.User(userId).SendAsync("ReceiveNotification", new
        {
            Title = title,
            Message = message,
            Timestamp = DateTime.UtcNow
        }, cancellationToken);
    }

    public async Task SendNotificationToAllAsync(string title, string message, CancellationToken cancellationToken = default)
    {
        await _hubContext.Clients.All.SendAsync("ReceiveNotification", new
        {
            Title = title,
            Message = message,
            Timestamp = DateTime.UtcNow
        }, cancellationToken);
    }
}
