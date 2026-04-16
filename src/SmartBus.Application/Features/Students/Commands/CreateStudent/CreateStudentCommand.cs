using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Commands.CreateStudent;

public record CreateStudentCommand(
    string FullName,
    string Grade,
    string? Class,
    DateOnly? DateOfBirth,
    string? Address,
    string ParentName,
    string ParentPhone,
    Guid? ParentId,
    Guid? RouteId,
    Guid? PickupStopId
) : IRequest<Result<Guid>>;
