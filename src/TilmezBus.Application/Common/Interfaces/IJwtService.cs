namespace TilmezBus.Application.Common.Interfaces;

public interface IJwtService
{
    string GenerateToken(string userId, string email, IEnumerable<string> roles);
    bool ValidateToken(string token);
    string? GetUserIdFromToken(string token);
}
