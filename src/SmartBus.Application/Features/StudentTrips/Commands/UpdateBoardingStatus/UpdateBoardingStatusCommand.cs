using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.StudentTrips.Commands.UpdateBoardingStatus;

public record UpdateBoardingStatusCommand(
    Guid TripId,
    Guid StudentId,
    BoardingStatus Status,
    DateTime? BoardingTime = null
) : IRequest<Result>;
