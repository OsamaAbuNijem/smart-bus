using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.StudentTrips.Commands.UpdateBoardingStatus;

/// <param name="Latitude">Assistant's GPS at the moment of boarding/dropoff.
/// On Morning trips we treat this as the student's home pickup point and
/// persist it to <c>Student.Latitude/Longitude</c>.</param>
public record UpdateBoardingStatusCommand(
    Guid TripId,
    Guid StudentId,
    BoardingStatus Status,
    DateTime? BoardingTime = null,
    double? Latitude = null,
    double? Longitude = null
) : IRequest<Result>;
