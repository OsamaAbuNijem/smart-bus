using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.AbsenceRequests.Commands.SubmitAbsenceRequest;

public class SubmitAbsenceRequestCommandHandler : IRequestHandler<SubmitAbsenceRequestCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public SubmitAbsenceRequestCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(SubmitAbsenceRequestCommand request, CancellationToken cancellationToken)
    {
        var student = await _unitOfWork.Students.GetByIdAsync(request.StudentId, cancellationToken);
        if (student is null) return Result<Guid>.Failure("Student not found.");

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
}
