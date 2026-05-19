using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Buses.Commands.CreateBus;

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
            Status      = status,
            // Stamp a one-shot QR token so admins can immediately print the
            // bus's QR sticker. Token is opaque — the mobile app POSTs it back
            // verbatim to /trips/scan to spin up a trip.
            QrToken     = Guid.NewGuid().ToString("N")
        };

        await _unitOfWork.Buses.AddAsync(bus, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<Guid>.Success(bus.Id);
    }
}
