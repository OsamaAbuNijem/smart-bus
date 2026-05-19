using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.Login;

public record LoginCommand(string Email, string Password) : IRequest<Result<LoginResponse>>;

public record LoginResponse(string Token, string Email, IEnumerable<string> Roles, DateTime ExpiresAt);
