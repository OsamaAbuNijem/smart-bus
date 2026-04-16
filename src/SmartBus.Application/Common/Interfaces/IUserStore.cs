namespace SmartBus.Application.Common.Interfaces;

public interface IUserStore
{
    Task<AppUser?> FindByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<bool> CheckPasswordAsync(string userId, string password, CancellationToken cancellationToken = default);
    Task<IEnumerable<string>> GetRolesAsync(string userId, CancellationToken cancellationToken = default);
}

public record AppUser(string Id, string Email, string FullName);
