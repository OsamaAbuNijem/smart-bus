using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.DeleteBus;

public class DeleteBusCommandHandler : IRequestHandler<DeleteBusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public DeleteBusCommandHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result> Handle(DeleteBusCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result.Failure("Bus not found.");

        // BusSchedule cascades (soft-delete), and BusScheduleStudents will cascade
        // at the SQL level if we hard-delete the schedule — but we soft-delete the bus,
        // so the schedule rows remain logically intact. No student-side cleanup needed.
        bus.IsDeleted = true;
        await _unitOfWork.Buses.UpdateAsync(bus);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
