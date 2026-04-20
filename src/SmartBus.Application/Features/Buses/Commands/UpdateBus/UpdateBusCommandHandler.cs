using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Buses.Commands.UpdateBus;

public class UpdateBusCommandHandler : IRequestHandler<UpdateBusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateBusCommandHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result> Handle(UpdateBusCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result.Failure("Bus not found.");

        var status = Enum.TryParse<BusStatus>(request.Status, out var s) ? s : bus.Status;

        bus.PlateNumber = request.PlateNumber;
        bus.Capacity    = request.Capacity;
        bus.Status      = status;

        await _unitOfWork.Buses.UpdateAsync(bus);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
