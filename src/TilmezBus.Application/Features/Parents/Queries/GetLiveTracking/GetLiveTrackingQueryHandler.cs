using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Parents.Queries.GetLiveTracking;

public class GetLiveTrackingQueryHandler
    : IRequestHandler<GetLiveTrackingQuery, Result<LiveTrackingDto>>
{
    private readonly IApplicationDbContext _db;
    public GetLiveTrackingQueryHandler(IApplicationDbContext db) => _db = db;

    public async Task<Result<LiveTrackingDto>> Handle(
        GetLiveTrackingQuery request, CancellationToken ct)
    {
        // Authorisation + base student data
        var student = await _db.Students
            .Where(s => s.Id == request.StudentId && s.ParentId == request.ParentId)
            .Select(s => new
            {
                s.Id,
                s.FullName,
                s.HomeArea,
                s.HomeStreet,
                s.HomeBuildingNumber,
                s.Latitude,
                s.Longitude,
                s.SchoolId,
            })
            .FirstOrDefaultAsync(ct);

        if (student is null)
            return Result<LiveTrackingDto>.Failure("الطالب غير موجود لهذا الولي.");

        string? schoolName = null;
        double? schoolLat = null, schoolLng = null;
        if (Guid.TryParse(student.SchoolId, out var schoolGuid))
        {
            var school = await _db.Schools
                .Where(sc => sc.Id == schoolGuid)
                .Select(sc => new { sc.Name, sc.Latitude, sc.Longitude })
                .FirstOrDefaultAsync(ct);
            schoolName = school?.Name;
            schoolLat = school?.Latitude;
            schoolLng = school?.Longitude;
        }

        var addressParts = new[]
        {
            student.HomeStreet,
            student.HomeBuildingNumber,
            student.HomeArea,
        }.Where(p => !string.IsNullOrWhiteSpace(p)).ToList();
        var homeAddress = addressParts.Count > 0 ? string.Join(", ", addressParts) : null;

        // Pick the most relevant trip:
        // - in-progress wins
        // - else nearest scheduled in the next ~3 days
        // - else fall back to the most recent trip ever (so the parent still
        //   sees a bus to track even between trip windows)
        var st = await _db.StudentTrips
            .Where(x => x.StudentId == request.StudentId)
            .Include(x => x.Trip).ThenInclude(t => t.Bus)
            .OrderBy(x => x.Trip.Status == TripStatus.InProgress ? 0
                : x.Trip.Status == TripStatus.Scheduled ? 1 : 2)
            .ThenByDescending(x => x.Trip.ScheduledDeparture)
            .FirstOrDefaultAsync(ct);

        if (st is null)
        {
            // No trip in window — return a sparse snapshot so the screen can render
            // student/home info while telling the user no trip is active.
            return Result<LiveTrackingDto>.Success(new LiveTrackingDto(
                TripId: null, TripStatus: null, TripType: null,
                ScheduledDeparture: null, ActualDeparture: null, ActualArrival: null,
                BoardingTime: null, BoardingStatus: null,
                BusId: null, BusPlateNumber: null, BusLocation: null,
                DriverName: null, DriverPhone: null,
                AssistantName: null, AssistantPhone: null,
                StudentFullName: student.FullName,
                HomeLatitude: student.Latitude,
                HomeLongitude: student.Longitude,
                HomeAddress: homeAddress,
                SchoolName: schoolName,
                SchoolLatitude: schoolLat,
                SchoolLongitude: schoolLng));
        }

        var trip = st.Trip;

        // Latest bus location
        var loc = await _db.BusLocations
            .Where(bl => bl.BusId == trip.BusId)
            .OrderByDescending(bl => bl.Timestamp)
            .Select(bl => new BusLocationDto(
                bl.Latitude, bl.Longitude, bl.Speed, bl.Heading, bl.Timestamp))
            .FirstOrDefaultAsync(ct);

        // Driver + assistant are both read from the trip — DriverId is the
        // person the assistant picked in trip setup; AssistantId is whoever
        // scanned the bus QR to start. Both columns may be null on legacy
        // trips, hence the guards.
        string? driverName = null, driverPhone = null;
        string? assistantName = null, assistantPhone = null;
        if (trip.DriverId is not null)
        {
            var driver = await _db.Drivers
                .Where(d => d.Id == trip.DriverId)
                .Select(d => new { d.FullName, d.PhoneNumber })
                .FirstOrDefaultAsync(ct);
            driverName = driver?.FullName;
            driverPhone = driver?.PhoneNumber;
        }
        if (trip.AssistantId is not null)
        {
            var assistant = await _db.Drivers
                .Where(d => d.Id == trip.AssistantId)
                .Select(d => new { d.FullName, d.PhoneNumber })
                .FirstOrDefaultAsync(ct);
            assistantName = assistant?.FullName;
            assistantPhone = assistant?.PhoneNumber;
        }

        return Result<LiveTrackingDto>.Success(new LiveTrackingDto(
            TripId: trip.Id,
            TripStatus: trip.Status.ToString(),
            TripType: trip.Type.ToString(),
            ScheduledDeparture: trip.ScheduledDeparture,
            ActualDeparture: trip.ActualDeparture,
            ActualArrival: trip.ActualArrival,
            BoardingTime: st.BoardingTime,
            BoardingStatus: st.BoardingStatus.ToString(),
            BusId: trip.BusId,
            BusPlateNumber: trip.Bus.PlateNumber,
            BusLocation: loc,
            DriverName: driverName,
            DriverPhone: driverPhone,
            AssistantName: assistantName,
            AssistantPhone: assistantPhone,
            StudentFullName: student.FullName,
            HomeLatitude: student.Latitude,
            HomeLongitude: student.Longitude,
            HomeAddress: homeAddress,
            SchoolName: schoolName,
            SchoolLatitude: schoolLat,
            SchoolLongitude: schoolLng));
    }
}
