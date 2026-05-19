using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Parents.Queries.GetStudentTrips;

public class GetStudentTripsQueryHandler
    : IRequestHandler<GetStudentTripsQuery, Result<List<StudentTripDetailDto>>>
{
    private const int LateThresholdMinutes = 5;

    private readonly IApplicationDbContext _db;

    public GetStudentTripsQueryHandler(IApplicationDbContext db) => _db = db;

    public async Task<Result<List<StudentTripDetailDto>>> Handle(
        GetStudentTripsQuery request, CancellationToken ct)
    {
        // Authorisation: ensure the requested student belongs to this parent.
        var student = await _db.Students
            .Where(s => s.Id == request.StudentId && s.ParentId == request.ParentId)
            .Select(s => new { s.Id, s.FullName, s.HomeArea, s.SchoolId })
            .FirstOrDefaultAsync(ct);

        if (student is null)
            return Result<List<StudentTripDetailDto>>.Failure("الطالب غير موجود لهذا الولي.");

        // SchoolId is a string but our School entity has a Guid Id — try to
        // parse and look up; fall back to a generic label otherwise.
        string schoolLabel = "School";
        if (Guid.TryParse(student.SchoolId, out var schoolGuid))
        {
            schoolLabel = await _db.Schools
                .Where(sc => sc.Id == schoolGuid)
                .Select(sc => sc.Name)
                .FirstOrDefaultAsync(ct) ?? "School";
        }

        var pageSize = Math.Clamp(request.PageSize, 1, 50);
        var homeLabel = string.IsNullOrWhiteSpace(student.HomeArea) ? "Home" : student.HomeArea!;

        // Pull StudentTrip rows (joined with Trip + Bus + Route + Driver + Assistant)
        // ordered most-recent first.
        var rows = await _db.StudentTrips
            .Where(st => st.StudentId == request.StudentId)
            .Include(st => st.Trip).ThenInclude(t => t.Bus)
            .Include(st => st.Trip).ThenInclude(t => t.Route)
            .OrderByDescending(st => st.Trip.ScheduledDeparture)
            .Take(pageSize)
            .Select(st => new
            {
                st.Trip,
                st.BoardingStatus,
                st.BoardingTime,
                st.DropoffTime,
            })
            .ToListAsync(ct);

        // Driver + assistant names via the BusSchedule of each trip's bus,
        // picked by TripType (Morning vs Return).
        var busIds = rows.Select(r => r.Trip.BusId).Distinct().ToList();
        var schedulesByBus = busIds.Count == 0
            ? new Dictionary<Guid, _ScheduleStaff>()
            : await _db.BusSchedules
                .Where(bs => busIds.Contains(bs.BusId))
                .Select(bs => new _ScheduleStaff
                {
                    BusId = bs.BusId,
                    MorningDriverName = bs.MorningDriver != null ? bs.MorningDriver.FullName : null,
                    MorningAssistantName = bs.MorningAssistant != null ? bs.MorningAssistant.FullName : null,
                    ReturnDriverName = bs.ReturnDriver != null ? bs.ReturnDriver.FullName : null,
                    ReturnAssistantName = bs.ReturnAssistant != null ? bs.ReturnAssistant.FullName : null,
                })
                .ToDictionaryAsync(s => s.BusId, ct);

        var result = rows.Select(r =>
        {
            var t = r.Trip;
            string? driver = null, assistant = null;
            if (schedulesByBus.TryGetValue(t.BusId, out var sched))
            {
                if (t.Type == TripType.Morning)
                {
                    driver = sched.MorningDriverName;
                    assistant = sched.MorningAssistantName;
                }
                else
                {
                    driver = sched.ReturnDriverName;
                    assistant = sched.ReturnAssistantName;
                }
            }

            var (pickup, dropoff) = t.Type == TripType.Morning
                ? (homeLabel, schoolLabel)
                : (schoolLabel, homeLabel);

            int? duration = (t.ActualArrival.HasValue && t.ActualDeparture.HasValue)
                ? (int)(t.ActualArrival.Value - t.ActualDeparture.Value).TotalMinutes
                : null;

            int? delay = t.ActualDeparture.HasValue
                ? (int)(t.ActualDeparture.Value - t.ScheduledDeparture).TotalMinutes
                : null;

            string resultTag = r.BoardingStatus switch
            {
                BoardingStatus.Absent => "Absent",
                _ when t.Status != TripStatus.Completed => "Pending",
                _ when delay.HasValue && delay.Value >= LateThresholdMinutes => "Late",
                _ => "OnTime",
            };

            return new StudentTripDetailDto(
                TripId: t.Id,
                TripType: t.Type.ToString(),
                TripDate: t.ScheduledDeparture,
                BusPlateNumber: t.Bus.PlateNumber,
                DriverName: driver,
                AssistantName: assistant,
                RouteName: t.Route?.Name,
                PickupStopName: pickup,
                DropoffStopName: dropoff,
                ScheduledDeparture: t.ScheduledDeparture,
                ActualDeparture: t.ActualDeparture,
                ActualArrival: t.ActualArrival,
                BoardingTime: r.BoardingTime,
                DropoffTime: r.DropoffTime,
                BoardingStatus: r.BoardingStatus.ToString(),
                TripStatus: t.Status.ToString(),
                DurationMinutes: duration,
                DelayMinutes: delay,
                ResultTag: resultTag);
        }).ToList();

        return Result<List<StudentTripDetailDto>>.Success(result);
    }

    private sealed class _ScheduleStaff
    {
        public Guid BusId { get; set; }
        public string? MorningDriverName { get; set; }
        public string? MorningAssistantName { get; set; }
        public string? ReturnDriverName { get; set; }
        public string? ReturnAssistantName { get; set; }
    }
}
