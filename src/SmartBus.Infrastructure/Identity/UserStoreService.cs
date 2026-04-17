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

    public async Task<(bool Created, string? Error)> CreateUserIfNotExistsAsync(
        string email, string fullName, string password, string role,
        CancellationToken cancellationToken = default)
    {
        if (await _userManager.FindByEmailAsync(email) is not null)
            return (false, null); // already exists — not an error

        var user = new ApplicationUser
        {
            UserName = email,
            Email = email,
            FullName = fullName,
            EmailConfirmed = true
        };

        var result = await _userManager.CreateAsync(user, password);
        if (!result.Succeeded)
            return (false, string.Join("; ", result.Errors.Select(e => e.Description)));

        await _userManager.AddToRoleAsync(user, role);
        return (true, null);
    }

    public async Task<(bool Succeeded, string? Error)> ChangePasswordAsync(
        string userId, string currentPassword, string newPassword,
        CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user is null)
            return (false, "المستخدم غير موجود.");

        var result = await _userManager.ChangePasswordAsync(user, currentPassword, newPassword);
        if (!result.Succeeded)
            return (false, string.Join(" ", result.Errors.Select(e => e.Description)));

        return (true, null);
    }
}
