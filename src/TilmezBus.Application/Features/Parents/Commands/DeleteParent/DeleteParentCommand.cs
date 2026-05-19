using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Parents.Commands.DeleteParent;

public record DeleteParentCommand(Guid ParentId) : IRequest<Result>;
