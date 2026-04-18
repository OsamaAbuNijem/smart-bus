using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.DeleteBus;

public class DeleteBusCommandHandler : IRequestHandler<DeleteBusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public DeleteBusCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context = context;
    }

    public async Task<Result> Handle(DeleteBusCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result.Failure("Bus not found.");

        // Unassign all students from this bus before deleting
        var assignedStudents = await _context.Students
            .Where(s => !s.IsDeleted && s.BusId == request.BusId)
            .ToListAsync(cancellationToken);
        foreach (var student in assignedStudents)
            student.BusId = null;

        bus.IsDeleted = true;
        await _unitOfWork.Buses.UpdateAsync(bus);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _context.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
