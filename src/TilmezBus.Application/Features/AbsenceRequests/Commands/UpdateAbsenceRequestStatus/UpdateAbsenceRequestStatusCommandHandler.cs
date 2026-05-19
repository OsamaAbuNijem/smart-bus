using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.AbsenceRequests.Commands.UpdateAbsenceRequestStatus;

public class UpdateAbsenceRequestStatusCommandHandler : IRequestHandler<UpdateAbsenceRequestStatusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateAbsenceRequestStatusCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(UpdateAbsenceRequestStatusCommand request, CancellationToken cancellationToken)
    {
        var absenceRequest = await _unitOfWork.AbsenceRequests.GetByIdAsync(request.RequestId, cancellationToken);
        if (absenceRequest is null) return Result.Failure("Absence request not found.");

        absenceRequest.Status = request.Status;
        await _unitOfWork.AbsenceRequests.UpdateAsync(absenceRequest);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
