using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.AbsenceRequests.Commands.SubmitAbsenceRequest;

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
