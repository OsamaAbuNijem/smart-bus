using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.RefreshToken;

public record RefreshTokenCommand(string RefreshToken)
    : IRequest<Result<RefreshTokenResponse>>;

public record RefreshTokenResponse(
    string Token,
    DateTime ExpiresAt,
    string RefreshToken
);
