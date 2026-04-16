using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Alerts.Commands.CreateAlert;

public class CreateAlertCommandHandler : IRequestHandler<CreateAlertCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateAlertCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(CreateAlertCommand request, CancellationToken cancellationToken)
    {
        var alert = new Alert
        {
            Title = request.Title,
            Message = request.Message,
            Severity = request.Severity,
            RelatedBusId = request.RelatedBusId,
            RelatedTripId = request.RelatedTripId,
            RelatedStudentId = request.RelatedStudentId
        };

        await _unitOfWork.Alerts.AddAsync(alert, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(alert.Id);
    }
}
