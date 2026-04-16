using Microsoft.AspNetCore.Identity;
using SmartBus.Application.Common.Interfaces;

namespace SmartBus.Infrastructure.Identity;

public class UserStoreService : IUserStore
{
    private readonly UserManager<ApplicationUser> _userManager;

    public UserStoreService(UserManager<ApplicationUser> userManager)
        => _userManager = userManager;

    public async Task<AppUser?> FindByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByEmailAsync(email);
        return user is null ? null : new AppUser(user.Id, user.Email!, user.FullName);
    }

    public async Task<bool> CheckPasswordAsync(string userId, string password, CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByIdAsync(userId);
        return user is not null && await _userManager.CheckPasswordAsync(user, password);
    }

    public async Task<IEnumerable<string>> GetRolesAsync(string userId, CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByIdAsync(userId);
        return user is null ? Enumerable.Empty<string>() : await _userManager.GetRolesAsync(user);
    }
}
