using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.StudentTrips.Queries.GetStudentsByTrip;

public record GetStudentsByTripQuery(Guid TripId) : IRequest<Result<IReadOnlyList<StudentTripDto>>>;

public record StudentTripDto(
    Guid StudentId, string StudentName, string Grade,
    BoardingStatus BoardingStatus, DateTime? BoardingTime
);
