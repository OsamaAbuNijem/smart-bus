namespace TilmezBus.Application.Common.Interfaces;

public interface IUserStore
{
    Task<AppUser?> FindByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<AppUser?> FindByIdAsync(string userId, CancellationToken cancellationToken = default);
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
    /// Force-sets a user's password without requiring the current one —
    /// used by SuperAdmin "reset school admin password". Internally goes
    /// through Identity's RemovePasswordAsync + AddPasswordAsync pair so
    /// the new password is hashed and the password-policy validators run.
    /// </summary>
    Task<(bool Succeeded, string? Error)> ResetPasswordByEmailAsync(
        string email, string newPassword,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Generate a single-use, time-bound password-reset token for the
    /// user identified by <paramref name="email"/>. Returns null when no
    /// user with that email exists — callers should still surface a
    /// generic success message to avoid leaking which addresses are
    /// registered.
    /// </summary>
    Task<string?> GeneratePasswordResetTokenAsync(string email, CancellationToken cancellationToken = default);

    /// <summary>
    /// Re-assign a user's email + username so login + forgot-password
    /// keep working after the SuperAdmin edits the matching school's
    /// AdminEmail. Returns:
    ///   * (true, null) when the old user was renamed successfully,
    ///   * (true, null) when no user exists for the old email (nothing
    ///     to do — caller still persists the school's new AdminEmail),
    ///   * (false, message) when the new email is already taken by
    ///     another account or Identity rejects the change.
    /// </summary>
    Task<(bool Succeeded, string? Error)> ChangeEmailAsync(
        string oldEmail, string newEmail,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Validate a previously-issued reset token and, on success, set the
    /// user's password. Wraps <c>UserManager.ResetPasswordAsync</c> so
    /// the same password-policy validators that gate Create / Change
    /// also gate Reset.
    /// </summary>
    Task<(bool Succeeded, string? Error)> ResetPasswordWithTokenAsync(
        string email, string token, string newPassword,
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

    /// <summary>
    /// Returns the ApplicationUser.Id of every user that's a member of the
    /// given role. Used by SuperAdmin broadcast fan-out.
    /// </summary>
    Task<IReadOnlyList<string>> GetUserIdsInRoleAsync(
        string role,
        CancellationToken cancellationToken = default);
}

public record AppUser(string Id, string Email, string FullName);
