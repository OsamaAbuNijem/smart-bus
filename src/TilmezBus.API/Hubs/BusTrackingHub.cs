using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace TilmezBus.API.Hubs;

[Authorize]
public class BusTrackingHub : Hub
{
    public async Task JoinBusGroup(string busId)
        => await Groups.AddToGroupAsync(Context.ConnectionId, $"bus-{busId}");

    public async Task LeaveBusGroup(string busId)
        => await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"bus-{busId}");

    public async Task JoinAdminGroup()
    {
        if (Context.User?.IsInRole("Admin") == true)
            await Groups.AddToGroupAsync(Context.ConnectionId, "admins");
    }

    public override async Task OnConnectedAsync()
    {
        await Clients.Caller.SendAsync("Connected", Context.ConnectionId);
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        await base.OnDisconnectedAsync(exception);
    }
}
