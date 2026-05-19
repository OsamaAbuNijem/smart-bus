using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.AbsenceRequests.Commands.CancelAbsenceRequest;

public class CancelAbsenceRequestCommandHandler
    : IRequestHandler<CancelAbsenceRequestCommand, Result>
{
    private readonly IApplicationDbContext _context;

    public CancelAbsenceRequestCommandHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result> Handle(
        CancelAbsenceRequestCommand request, CancellationToken ct)
    {
        var absence = await _context.AbsenceRequests
            .FirstOrDefaultAsync(a => a.Id == request.Id && !a.IsDeleted, ct);
        if (absence is null) return Result.Failure("Absence request not found.");

        // Block cancel once a trip covering the requested leg on that date
        // has moved past Scheduled — by then the assistant/driver is already
        // operating against the absence.
        var startOfDay = absence.Date.ToDateTime(TimeOnly.MinValue).ToUniversalTime();
        var endOfDay = startOfDay.AddDays(1);

        var startedTripTypes = await _context.StudentTrips
            .Where(st => st.StudentId == absence.StudentId
                         && !st.Trip.IsTemplate
                         && st.Trip.Status != TripStatus.Scheduled
                         && st.Trip.ScheduledDeparture >= startOfDay
                         && st.Trip.ScheduledDeparture <  endOfDay)
            .Select(st => st.Trip.Type)
            .Distinct()
            .ToListAsync(ct);

        var conflicts = startedTripTypes.Any(tripType =>
            absence.TripType == AbsenceTripType.FullDay ||
            (absence.TripType == AbsenceTripType.MorningOnly && tripType == TripType.Morning) ||
            (absence.TripType == AbsenceTripType.ReturnOnly  && tripType == TripType.Return));
        if (conflicts)
        {
            return Result.Failure(
                "The trip has already started. The absence can no longer be cancelled.");
        }

        absence.IsDeleted = true;
        await _context.SaveChangesAsync(ct);
        return Result.Success();
    }
}
