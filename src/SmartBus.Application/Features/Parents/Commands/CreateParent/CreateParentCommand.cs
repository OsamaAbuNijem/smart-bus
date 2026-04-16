using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Parents.Commands.CreateParent;

public record CreateParentCommand(string FullName, string PhoneNumber) : IRequest<Result<Guid>>;
