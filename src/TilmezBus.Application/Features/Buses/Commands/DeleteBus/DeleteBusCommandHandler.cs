using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Buses.Commands.DeleteBus;

public class DeleteBusCommandHandler : IRequestHandler<DeleteBusCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public DeleteBusCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
    }

    public async Task<Result> Handle(DeleteBusCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result.Failure("Bus not found.");

        // Soft-delete dependents so they don't linger as orphans in the trips grid.
        var orphanTrips = await _context.Trips
            .Where(t => t.BusId == request.BusId && !t.IsDeleted)
            .ToListAsync(cancellationToken);
        foreach (var trip in orphanTrips) trip.IsDeleted = true;

        var orphanSchedule = await _context.BusSchedules
            .FirstOrDefaultAsync(s => s.BusId == request.BusId && !s.IsDeleted, cancellationToken);
        if (orphanSchedule is not null) orphanSchedule.IsDeleted = true;

        bus.IsDeleted = true;
        await _unitOfWork.Buses.UpdateAsync(bus);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
