using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Assistants.Commands.DeleteAssistant;

public record DeleteAssistantCommand(Guid AssistantId) : IRequest<Result>;
