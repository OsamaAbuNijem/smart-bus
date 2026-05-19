using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Parents.Commands.CreateParent;

public record CreateParentCommand(string FullName, string PhoneNumber) : IRequest<Result<Guid>>;
