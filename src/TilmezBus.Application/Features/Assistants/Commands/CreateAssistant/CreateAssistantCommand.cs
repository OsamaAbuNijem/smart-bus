using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Assistants.Commands.CreateAssistant;

public record CreateAssistantCommand(string FullName, string PhoneNumber) : IRequest<Result<Guid>>;
