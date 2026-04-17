using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Schools.Commands.DeleteSchool;

public record DeleteSchoolCommand(Guid SchoolId) : IRequest<Result>;
