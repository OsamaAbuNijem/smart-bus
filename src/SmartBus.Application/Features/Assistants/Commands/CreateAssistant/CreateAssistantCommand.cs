using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Assistants.Commands.CreateAssistant;

public record CreateAssistantCommand(string FullName, string PhoneNumber) : IRequest<Result<Guid>>;
