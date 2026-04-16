using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.AbsenceRequests.Queries.GetAbsenceRequestsByStudent;

public record GetAbsenceRequestsByStudentQuery(Guid StudentId) : IRequest<Result<IReadOnlyList<AbsenceRequestDto>>>;

public record AbsenceRequestDto(
    Guid Id, Guid StudentId, string StudentName, DateOnly Date,
    AbsenceTripType TripType, AbsenceReason Reason,
    AbsenceRequestStatus Status, DateTime CreatedAt
);
