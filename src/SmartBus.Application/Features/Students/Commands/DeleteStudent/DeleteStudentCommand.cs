using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Commands.DeleteStudent;

public record DeleteStudentCommand(Guid StudentId) : IRequest<Result>;
