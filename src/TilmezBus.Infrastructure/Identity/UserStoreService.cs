using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;

namespace TilmezBus.Infrastructure.Identity;

public class UserStoreService : IUserStore
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly RoleManager<IdentityRole>    _roleManager;

    public UserStoreService(
        UserManager<ApplicationUser> userManager,
        RoleManager<IdentityRole>    roleManager)
    {
        _userManager = userManager;
        _roleManager = roleManager;
    }

    public async Task<AppUser?> FindByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByEmailAsync(email);
        return user is null ? null : new AppUser(user.Id, user.Email!, user.FullName);
    }

    public async Task<AppUser?> FindByIdAsync(string userId, CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByIdAsync(userId);
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

    public async Task<(bool Succeeded, string? Error)> ResetPasswordByEmailAsync(
        string email, string newPassword,
        CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user is null)
            return (false, "User not found for that email.");

        // Drop the existing hash then add the new one. AddPasswordAsync
        // runs the configured PasswordValidator pipeline, so weak passwords
        // are rejected with a descriptive error.
        var remove = await _userManager.RemovePasswordAsync(user);
        if (!remove.Succeeded)
            return (false, string.Join(" ", remove.Errors.Select(e => e.Description)));
        var add = await _userManager.AddPasswordAsync(user, newPassword);
        if (!add.Succeeded)
            return (false, string.Join(" ", add.Errors.Select(e => e.Description)));
        return (true, null);
    }

    public async Task<string?> GeneratePasswordResetTokenAsync(
        string email, CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user is null) return null;
        // Default token provider is data-protected (signed + bound to
        // user.SecurityStamp + a short TTL configured on Identity).
        return await _userManager.GeneratePasswordResetTokenAsync(user);
    }

    public async Task<(bool Succeeded, string? Error)> ResetPasswordWithTokenAsync(
        string email, string token, string newPassword,
        CancellationToken cancellationToken = default)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user is null)
            return (false, "Invalid or expired reset link.");

        var result = await _userManager.ResetPasswordAsync(user, token, newPassword);
        if (!result.Succeeded)
            return (false, string.Join(" ", result.Errors.Select(e => e.Description)));
        // Rotate SecurityStamp so any other in-flight reset tokens for
        // this user become invalid.
        await _userManager.UpdateSecurityStampAsync(user);
        return (true, null);
    }

    public async Task<int> CountActiveUsersByRoleAsync(
        string role, TimeSpan window,
        CancellationToken cancellationToken = default)
    {
        // Resolve the role first; bail early when the role doesn't exist
        // so we don't trip an exception on an Identity lookup.
        var roleEntity = await _roleManager.FindByNameAsync(role);
        if (roleEntity is null) return 0;

        // GetUsersInRoleAsync is a single SQL join under the hood and the
        // populations we care about (Parent / Driver / Assistant) are
        // bounded — fine to filter the result in memory.
        var users     = await _userManager.GetUsersInRoleAsync(role);
        var threshold = DateTime.UtcNow - window;
        return users.Count(u => u.LastSeenAt is { } seen && seen >= threshold);
    }

    public async Task<IReadOnlyList<string>> GetUserIdsInRoleAsync(
        string role,
        CancellationToken cancellationToken = default)
    {
        var roleEntity = await _roleManager.FindByNameAsync(role);
        if (roleEntity is null) return Array.Empty<string>();
        var users = await _userManager.GetUsersInRoleAsync(role);
        return users.Select(u => u.Id).ToList();
    }
}
