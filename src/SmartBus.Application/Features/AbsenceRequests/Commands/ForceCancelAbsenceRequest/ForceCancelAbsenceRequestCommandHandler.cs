using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.AbsenceRequests.Commands.ForceCancelAbsenceRequest;

public class ForceCancelAbsenceRequestCommandHandler
    : IRequestHandler<ForceCancelAbsenceRequestCommand, Result>
{
    private readonly IApplicationDbContext _context;

    public ForceCancelAbsenceRequestCommandHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result> Handle(
        ForceCancelAbsenceRequestCommand request, CancellationToken ct)
    {
        var absence = await _context.AbsenceRequests
            .FirstOrDefaultAsync(a => a.Id == request.Id && !a.IsDeleted, ct);
        if (absence is null) return Result.Failure("Absence request not found.");

        var startOfDay = absence.Date.ToDateTime(TimeOnly.MinValue).ToUniversalTime();
        var endOfDay = startOfDay.AddDays(1);

        var completedTripTypes = await _context.StudentTrips
            .Where(st => st.StudentId == absence.StudentId
                         && !st.Trip.IsTemplate
                         && st.Trip.Status == TripStatus.Completed
                         && st.Trip.ScheduledDeparture >= startOfDay
                         && st.Trip.ScheduledDeparture <  endOfDay)
            .Select(st => st.Trip.Type)
            .Distinct()
            .ToListAsync(ct);

        var conflicts = completedTripTypes.Any(tripType =>
            absence.TripType == AbsenceTripType.FullDay ||
            (absence.TripType == AbsenceTripType.MorningOnly && tripType == TripType.Morning) ||
            (absence.TripType == AbsenceTripType.ReturnOnly  && tripType == TripType.Return));
        if (conflicts)
        {
            return Result.Failure(
                "The matching trip is already completed. The absence can no longer be cancelled.");
        }

        absence.IsDeleted = true;
        await _context.SaveChangesAsync(ct);
        return Result.Success();
    }
}
