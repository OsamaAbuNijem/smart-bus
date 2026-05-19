using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Alerts.Commands.UpdateAlertStatus;

public class UpdateAlertStatusCommandHandler : IRequestHandler<UpdateAlertStatusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateAlertStatusCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(UpdateAlertStatusCommand request, CancellationToken cancellationToken)
    {
        var alert = await _unitOfWork.Alerts.GetByIdAsync(request.AlertId, cancellationToken);
        if (alert is null) return Result.Failure("Alert not found.");

        if (request.Status == AlertStatus.ActionTaken) alert.Resolve();
        else if (request.Status == AlertStatus.Ignored) alert.Ignore();

        await _unitOfWork.Alerts.UpdateAsync(alert);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
