using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Commands.CancelEmptyTrip;

public class CancelEmptyTripCommandHandler
    : IRequestHandler<CancelEmptyTripCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public CancelEmptyTripCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
    }

    public async Task<Result> Handle(
        CancelEmptyTripCommand request, CancellationToken ct)
    {
        var trip = await _unitOfWork.Trips.GetByIdAsync(request.TripId, ct);
        if (trip is null) return Result.Failure("Trip not found.");
        if (trip.Status == TripStatus.Completed)
            return Result.Failure("This trip is already completed.");

        var studentCount = await _context.StudentTrips
            .CountAsync(st => st.TripId == request.TripId, ct);
        if (studentCount > 0)
            return Result.Failure(
                "Trip is not empty. End it instead of deleting.");

        await _unitOfWork.Trips.DeleteAsync(trip);
        await _unitOfWork.SaveChangesAsync(ct);
        return Result.Success();
    }
}
