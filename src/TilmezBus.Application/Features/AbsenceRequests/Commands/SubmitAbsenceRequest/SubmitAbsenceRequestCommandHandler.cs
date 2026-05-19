using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.AbsenceRequests.Commands.SubmitAbsenceRequest;

public class SubmitAbsenceRequestCommandHandler : IRequestHandler<SubmitAbsenceRequestCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public SubmitAbsenceRequestCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
    }

    public async Task<Result<Guid>> Handle(SubmitAbsenceRequestCommand request, CancellationToken cancellationToken)
    {
        var student = await _unitOfWork.Students.GetByIdAsync(request.StudentId, cancellationToken);
        if (student is null) return Result<Guid>.Failure("Student not found.");

        // Block duplicate same-day absences. FullDay collides with anything;
        // MorningOnly / ReturnOnly only collide with the matching leg or
        // a FullDay request. Rejected requests are ignored so the parent can
        // retry after an admin rejection.
        var sameDay = await _context.AbsenceRequests
            .Where(a => !a.IsDeleted
                        && a.StudentId == request.StudentId
                        && a.Date == request.Date
                        && a.Status != AbsenceRequestStatus.Rejected)
            .Select(a => a.TripType)
            .ToListAsync(cancellationToken);

        if (sameDay.Any(t => OverlapsWith(t, request.TripType)))
        {
            return Result<Guid>.Failure(
                "You already have an absence request for this day. Cancel it before submitting a new one.");
        }

        var absenceRequest = new AbsenceRequest
        {
            StudentId = request.StudentId,
            Date = request.Date,
            TripType = request.TripType,
            Reason = request.Reason,
            PickupPersonName = request.PickupPersonName,
            PickupPersonRelation = request.PickupPersonRelation,
            DriverNote = request.DriverNote,
            NotifyDriver = request.NotifyDriver,
            NotifySchool = request.NotifySchool
        };

        await _unitOfWork.AbsenceRequests.AddAsync(absenceRequest, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(absenceRequest.Id);
    }

    private static bool OverlapsWith(AbsenceTripType existing, AbsenceTripType incoming)
    {
        if (existing == AbsenceTripType.FullDay || incoming == AbsenceTripType.FullDay)
            return true;
        return existing == incoming;
    }
}
