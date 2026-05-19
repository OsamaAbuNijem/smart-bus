using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Trips.Queries.GetTripStudents;

public record GetTripStudentsQuery(Guid TripId) : IRequest<Result<List<TripStudentDto>>>;

public record TripStudentDto(
    Guid   StudentId,
    string FullName,
    string Grade,
    string? HomeArea,
    string BoardingStatus,
    DateTime? BoardingTime,
    DateTime? DropoffTime
);
