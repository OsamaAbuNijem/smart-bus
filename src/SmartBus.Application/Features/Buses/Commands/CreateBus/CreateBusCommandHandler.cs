using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Buses.Commands.CreateBus;

public class CreateBusCommandHandler : IRequestHandler<CreateBusCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public CreateBusCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context = context;
    }

    public async Task<Result<Guid>> Handle(CreateBusCommand request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.Buses.GetByPlateNumberAsync(request.PlateNumber, cancellationToken);
        if (existing is not null)
            return Result<Guid>.Failure($"Bus with plate number '{request.PlateNumber}' already exists.");

        var status = Enum.TryParse<BusStatus>(request.Status, out var s) ? s : BusStatus.Inactive;

        var bus = new Bus
        {
            PlateNumber       = request.PlateNumber,
            Capacity          = request.Capacity,
            Status            = status,
            DriverId          = request.DriverId,
            AssistantDriverId = request.AssistantDriverId
        };

        await _unitOfWork.Buses.AddAsync(bus, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // Assign students
        var studentIds = request.StudentIds?.ToList() ?? [];
        if (studentIds.Count > 0)
        {
            var students = await _context.Students
                .Where(s => !s.IsDeleted && studentIds.Contains(s.Id))
                .ToListAsync(cancellationToken);
            foreach (var st in students) st.BusId = bus.Id;
            await _context.SaveChangesAsync(cancellationToken);
        }

        return Result<Guid>.Success(bus.Id);
    }
}
