using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Commands.UpdateStudent;

public record UpdateStudentCommand(
    Guid StudentId,
    string FullName,
    string? FullNameEn,
    string Grade,
    string? Class,
    DateOnly? DateOfBirth,
    string? Address,
    string ParentName,
    string? ParentNameEn,
    string ParentPhone,
    Guid? RouteId,
    Guid? PickupStopId,
    double? Latitude,
    double? Longitude,
    string? HomeArea,
    string? HomeStreet,
    string? HomeBuildingNumber
) : IRequest<Result>;
