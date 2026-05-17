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

        if (!string.IsNullOrWhiteSpace(request.PlateNumber))
        {
            var newPlate = request.PlateNumber.Trim();
            if (!string.Equals(bus.PlateNumber, newPlate, StringComparison.Ordinal))
            {
                var clash = await _unitOfWork.Buses.GetByPlateNumberAsync(newPlate, cancellationToken);
                if (clash is not null && clash.Id != bus.Id)
                    return Result.Failure($"Bus number '{newPlate}' is already in use.");
                bus.PlateNumber = newPlate;
            }
        }
        if (request.Capacity is int cap)
            bus.Capacity = cap;
        if (!string.IsNullOrWhiteSpace(request.Status)
            && Enum.TryParse<BusStatus>(request.Status, true, out var s))
            bus.Status = s;

        await _unitOfWork.Buses.UpdateAsync(bus);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
