using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.AbsenceRequests.Queries.GetAbsenceRequestsByStudent;

public record GetAbsenceRequestsByStudentQuery(Guid StudentId) : IRequest<Result<IReadOnlyList<AbsenceRequestDto>>>;

public record AbsenceRequestDto(
    Guid Id, Guid StudentId, string StudentName, DateOnly Date,
    AbsenceTripType TripType, AbsenceReason Reason,
    AbsenceRequestStatus Status, DateTime CreatedAt,
    // True only while no trip covering this leg + date has moved past
    // Scheduled. The parent UI uses this to decide whether the delete
    // affordance is shown.
    bool CanCancel
);
