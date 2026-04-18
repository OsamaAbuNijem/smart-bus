using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Trips.Commands.SetBusSchedule;

public class SetBusScheduleCommandHandler : IRequestHandler<SetBusScheduleCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public SetBusScheduleCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
    }

    public async Task<Result> Handle(SetBusScheduleCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null) return Result.Failure("Bus not found.");

        if (!TimeOnly.TryParse(request.MorningTime, out var morningTime))
            return Result.Failure("Invalid morning time format. Use HH:mm.");
        if (!TimeOnly.TryParse(request.ReturnTime, out var returnTime))
            return Result.Failure("Invalid return time format. Use HH:mm.");

        // Upsert — one record per bus
        var existing = await _context.BusSchedules
            .IgnoreQueryFilters()          // include soft-deleted so we can resurrect
            .FirstOrDefaultAsync(s => s.BusId == request.BusId, cancellationToken);

        if (existing is null)
        {
            var schedule = new BusSchedule
            {
                BusId       = request.BusId,
                MorningTime = morningTime,
                ReturnTime  = returnTime,
                RepeatDays  = request.RepeatDays,
                IsDeleted   = false
            };
            _context.BusSchedules.Add(schedule);
        }
        else
        {
            existing.MorningTime = morningTime;
            existing.ReturnTime  = returnTime;
            existing.RepeatDays  = request.RepeatDays;
            existing.IsDeleted   = false;
        }

        await _context.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
