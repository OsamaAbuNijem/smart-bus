using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.AbsenceRequests.Commands.SubmitAbsenceRequest;

public record SubmitAbsenceRequestCommand(
    Guid StudentId,
    DateOnly Date,
    AbsenceTripType TripType,
    AbsenceReason Reason,
    string? PickupPersonName,
    string? PickupPersonRelation,
    string? DriverNote,
    bool NotifyDriver = true,
    bool NotifySchool = true
) : IRequest<Result<Guid>>;
