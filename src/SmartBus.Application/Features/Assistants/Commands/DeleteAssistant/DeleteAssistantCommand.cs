using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Assistants.Commands.DeleteAssistant;

public record DeleteAssistantCommand(Guid AssistantId) : IRequest<Result>;
