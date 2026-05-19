using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.DemoRequests.Commands.CreateDemoRequest;

/// <summary>
/// Public "Request a demo" submission from the marketing landing page.
/// No auth required at the API boundary; handler trims input and saves.
/// </summary>
public record CreateDemoRequestCommand(
    string  SchoolName,
    string  ContactName,
    string  Email,
    string? PhoneNumber,
    string? Notes
) : IRequest<Result<Guid>>;
