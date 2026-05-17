using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Buses.Commands.CreateBusesBatch;

public class CreateBusesBatchCommandHandler : IRequestHandler<CreateBusesBatchCommand, Result<int>>
{
    private const string Prefix     = "BUS-";
    private const int    PadWidth   = 4;
    private const int    DefaultCapacity = 50;
    private const int    MaxBatch   = 200;

    private readonly IApplicationDbContext _context;

    public CreateBusesBatchCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<int>> Handle(CreateBusesBatchCommand request, CancellationToken cancellationToken)
    {
        if (request.Count <= 0)            return Result<int>.Failure("Count must be at least 1.");
        if (request.Count >  MaxBatch)     return Result<int>.Failure($"Cannot create more than {MaxBatch} buses at once.");
        if (request.SchoolId == Guid.Empty) return Result<int>.Failure("Missing school context.");

        // Pull existing BUS-#### plates for THIS school so the serial range
        // is per-school (two schools can each have BUS-0001).
        var existingPlates = await _context.Buses
            .Where(b => !b.IsDeleted && b.SchoolId == request.SchoolId && b.PlateNumber.StartsWith(Prefix))
            .Select(b => b.PlateNumber)
            .ToListAsync(cancellationToken);

        var maxSerial = 0;
        foreach (var p in existingPlates)
        {
            if (int.TryParse(p.Substring(Prefix.Length), out var n) && n > maxSerial)
                maxSerial = n;
        }

        var batch = new List<Bus>(request.Count);
        for (var i = 1; i <= request.Count; i++)
        {
            batch.Add(new Bus
            {
                PlateNumber = $"{Prefix}{(maxSerial + i).ToString($"D{PadWidth}")}",
                Capacity    = DefaultCapacity,
                Status      = BusStatus.Active,
                QrToken     = Guid.NewGuid().ToString("N"),
                SchoolId    = request.SchoolId
            });
        }

        await _context.Buses.AddRangeAsync(batch, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        return Result<int>.Success(batch.Count);
    }
}
