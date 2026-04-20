using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Buses.Commands.CreateBus;

public class CreateBusCommandHandler : IRequestHandler<CreateBusCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateBusCommandHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<Guid>> Handle(CreateBusCommand request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.Buses.GetByPlateNumberAsync(request.PlateNumber, cancellationToken);
        if (existing is not null)
            return Result<Guid>.Failure($"Bus with plate number '{request.PlateNumber}' already exists.");

        var status = Enum.TryParse<BusStatus>(request.Status, out var s) ? s : BusStatus.Inactive;

        var bus = new Bus
        {
            PlateNumber = request.PlateNumber,
            Capacity    = request.Capacity,
            Status      = status
        };

        await _unitOfWork.Buses.AddAsync(bus, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<Guid>.Success(bus.Id);
    }
}
