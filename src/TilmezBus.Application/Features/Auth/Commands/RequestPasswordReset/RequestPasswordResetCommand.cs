using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Auth.Commands.RequestPasswordReset;

/// <param name="Email">School admin's email (case-insensitive — Identity normalises).</param>
public record RequestPasswordResetCommand(string Email) : IRequest<Result>;
