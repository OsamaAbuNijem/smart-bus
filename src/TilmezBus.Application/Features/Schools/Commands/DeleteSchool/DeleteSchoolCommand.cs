using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Schools.Commands.DeleteSchool;

public record DeleteSchoolCommand(Guid SchoolId) : IRequest<Result>;
