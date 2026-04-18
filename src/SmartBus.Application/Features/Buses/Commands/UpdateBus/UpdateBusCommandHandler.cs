using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Buses.Commands.UpdateBus;

public class UpdateBusCommandHandler : IRequestHandler<UpdateBusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public UpdateBusCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context = context;
    }

    public async Task<Result> Handle(UpdateBusCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result.Failure("Bus not found.");

        var status = Enum.TryParse<BusStatus>(request.Status, out var s) ? s : bus.Status;

        bus.PlateNumber       = request.PlateNumber;
        bus.Capacity          = request.Capacity;
        bus.Status            = status;
        bus.DriverId          = request.DriverId;
        bus.AssistantDriverId = request.AssistantDriverId;

        await _unitOfWork.Buses.UpdateAsync(bus);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // Re-assign students: clear previous, set new
        var newStudentIds = request.StudentIds?.ToList() ?? [];

        var previousStudents = await _context.Students
            .Where(s => !s.IsDeleted && s.BusId == request.BusId)
            .ToListAsync(cancellationToken);
        foreach (var st in previousStudents) st.BusId = null;

        if (newStudentIds.Count > 0)
        {
            var newStudents = await _context.Students
                .Where(s => !s.IsDeleted && newStudentIds.Contains(s.Id))
                .ToListAsync(cancellationToken);
            foreach (var st in newStudents) st.BusId = request.BusId;
        }

        await _context.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
