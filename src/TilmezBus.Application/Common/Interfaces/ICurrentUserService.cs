namespace TilmezBus.Application.Common.Interfaces;

public interface ICurrentUserService
{
    string? UserId { get; }
    string? UserName { get; }
    IEnumerable<string> Roles { get; }
    bool IsAuthenticated { get; }
}
