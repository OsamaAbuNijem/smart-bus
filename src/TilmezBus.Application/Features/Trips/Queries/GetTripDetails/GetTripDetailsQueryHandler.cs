using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Trips.Queries.GetTripDetails;

public class GetTripDetailsQueryHandler
    : IRequestHandler<GetTripDetailsQuery, Result<TripDetailsDto>>
{
    private readonly IApplicationDbContext _context;

    public GetTripDetailsQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<TripDetailsDto>> Handle(
        GetTripDetailsQuery request, CancellationToken ct)
    {
        var trip = await _context.Trips
            .Include(t => t.Bus)
            .FirstOrDefaultAsync(t => t.Id == request.TripId, ct);

        if (trip is null)
            return Result<TripDetailsDto>.Failure("Trip not found.");

        // Driver is whoever scanned the bus QR to start the trip. The
        // BusSchedule fallback is gone with the schedule table.
        Guid? driverId = trip.DriverId;
        string? driverName = null;
        if (driverId is not null)
        {
            driverName = await _context.Drivers
                .Where(d => d.Id == driverId)
                .Select(d => d.FullName)
                .FirstOrDefaultAsync(ct);
        }

        // Absences are scoped to THIS trip — same calendar date and matching
        // leg (FullDay always counts; MorningOnly only matches a Morning trip;
        // ReturnOnly only matches a Return trip). Old trips no longer pick up
        // absences filed for a different day or different leg.
        var tripDate = DateOnly.FromDateTime(trip.ScheduledDeparture);
        var legFilter = trip.Type == TripType.Morning
            ? AbsenceTripType.MorningOnly
            : AbsenceTripType.ReturnOnly;

        var absenceRows = await _context.AbsenceRequests
            .Where(a => a.Date == tripDate
                        && !a.IsDeleted
                        && a.Status != AbsenceRequestStatus.Rejected
                        && (a.TripType == AbsenceTripType.FullDay
                            || a.TripType == legFilter))
            .Select(a => new
            {
                a.Id,
                a.StudentId,
                a.Reason,
                a.PickupPersonName,
                a.PickupPersonRelation,
                a.DriverNote,
            })
            .ToListAsync(ct);
        // Multiple rows per student (e.g. FullDay + leg-specific) collapse
        // to the first.
        var absenceByStudent = absenceRows
            .GroupBy(a => a.StudentId)
            .ToDictionary(g => g.Key, g => g.First());

        var rows = await _context.StudentTrips
            .Where(st => st.TripId == request.TripId)
            .Include(st => st.Student)
            .ThenInclude(s => s.Parent)
            .Select(st => new
            {
                st.StudentId,
                st.Student.FullName,
                st.Student.FullNameEn,
                st.Student.Grade,
                st.Student.Class,
                st.Student.HomeArea,
                st.Student.Latitude,
                st.Student.Longitude,
                st.BoardingStatus,
                st.BoardingTime,
                st.DropoffTime,
                ParentName = st.Student.Parent != null ? st.Student.Parent.FullName : null,
                ParentPhone = st.Student.Parent != null ? st.Student.Parent.PhoneNumber : null,
            })
            .ToListAsync(ct);

        var students = rows
            .Select(r =>
            {
                var absence = absenceByStudent.GetValueOrDefault(r.StudentId);
                var isAbsent = absence is not null;
                var status = isAbsent
                    ? "Absent"
                    : r.BoardingStatus.ToString();
                return new TripStudentDetailDto(
                    r.StudentId,
                    r.FullName,
                    r.FullNameEn,
                    r.Grade,
                    r.Class,
                    r.HomeArea,
                    r.Latitude,
                    r.Longitude,
                    status,
                    r.BoardingTime,
                    r.DropoffTime,
                    isAbsent,
                    absence?.Reason.ToString(),
                    absence?.PickupPersonName,
                    absence?.PickupPersonRelation,
                    absence?.DriverNote,
                    absence?.Id,
                    r.ParentName,
                    r.ParentPhone);
            })
            // Sort by HomeArea (groups in the UI), then by name within an area.
            // Absent students fall to the bottom of each group (they get the
            // empty-string sort key by-design only when HomeArea is null).
            .OrderBy(s => s.HomeArea ?? string.Empty)
            .ThenBy(s => s.IsAbsentToday ? 1 : 0)
            .ThenBy(s => s.FullName)
            .ToList();

        var boarded   = students.Count(s => s.BoardingStatus == "Boarded");
        var droppedOff = students.Count(s => s.BoardingStatus == "DroppedOff");

        // Single-tenant for now — there's only ever one School row, so just
        // grab it for the route map's school marker. (When multi-tenant
        // lands, scope this through the trip's bus / school relationship.)
        var school = await _context.Schools
            .Select(s => new
            {
                s.Name,
                s.Latitude,
                s.Longitude,
            })
            .FirstOrDefaultAsync(ct);

        return Result<TripDetailsDto>.Success(new TripDetailsDto(
            trip.Id,
            trip.Type.ToString(),
            trip.Status.ToString(),
            trip.BusId,
            trip.Bus!.PlateNumber,
            driverId,
            driverName,
            trip.ScheduledDeparture,
            trip.ActualDeparture,
            trip.ActualArrival,
            students.Count,
            boarded,
            droppedOff,
            school?.Name,
            school?.Latitude,
            school?.Longitude,
            students));
    }
}
