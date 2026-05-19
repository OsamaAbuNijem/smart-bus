using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.StudentTrips.Queries.GetStudentsByTrip;

public record GetStudentsByTripQuery(Guid TripId) : IRequest<Result<IReadOnlyList<StudentTripDto>>>;

public record StudentTripDto(
    Guid StudentId, string StudentName, string Grade,
    BoardingStatus BoardingStatus, DateTime? BoardingTime
);
