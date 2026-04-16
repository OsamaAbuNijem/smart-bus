using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Buses.Commands.UpdateBusLocation;

public class UpdateBusLocationCommandHandler : IRequestHandler<UpdateBusLocationCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly ISignalRNotificationService _notificationService;
    private readonly ICacheService _cacheService;

    public UpdateBusLocationCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        ISignalRNotificationService notificationService,
        ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _context = context;
        _notificationService = notificationService;
        _cacheService = cacheService;
    }

    public async Task<Result> Handle(UpdateBusLocationCommand request, CancellationToken cancellationToken)
    {
        var bus = await _unitOfWork.Buses.GetByIdAsync(request.BusId, cancellationToken);
        if (bus is null)
            return Result.Failure($"Bus with ID '{request.BusId}' not found.");

        var location = new BusLocation
        {
            BusId = request.BusId,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            Speed = request.Speed,
            Heading = request.Heading,
            Timestamp = DateTime.UtcNow
        };

        await _context.BusLocations.AddAsync(location, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        var cacheKey = $"bus-location:{request.BusId}";
        await _cacheService.SetAsync(cacheKey, location, TimeSpan.FromMinutes(5), cancellationToken);

        await _notificationService.SendBusLocationUpdateAsync(
            request.BusId, request.Latitude, request.Longitude, request.Speed, cancellationToken);

        return Result.Success();
    }
}
