namespace SmartBus.Application.Common.Interfaces;

public interface IUserStore
{
    Task<AppUser?> FindByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<bool> CheckPasswordAsync(string userId, string password, CancellationToken cancellationToken = default);
    Task<IEnumerable<string>> GetRolesAsync(string userId, CancellationToken cancellationToken = default);

    /// <summary>Creates an Identity user with the given role if one does not already exist.</summary>
    Task<(bool Created, string? Error)> CreateUserIfNotExistsAsync(
        string email, string fullName, string password, string role,
        CancellationToken cancellationToken = default);

    /// <summary>Changes a user's password after verifying the current password.</summary>
    Task<(bool Succeeded, string? Error)> ChangePasswordAsync(
        string userId, string currentPassword, string newPassword,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Counts ApplicationUsers that are members of the given role AND have
    /// pinged the API within <paramref name="window"/> (their LastSeenAt is
    /// within that window). Powers the SuperAdmin dashboard's "currently
    /// active users by role" widget.
    /// </summary>
    Task<int> CountActiveUsersByRoleAsync(
        string role, TimeSpan window,
        CancellationToken cancellationToken = default);
}

public record AppUser(string Id, string Email, string FullName);
