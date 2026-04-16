using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Parents.Commands.DeleteParent;

public record DeleteParentCommand(Guid ParentId) : IRequest<Result>;
