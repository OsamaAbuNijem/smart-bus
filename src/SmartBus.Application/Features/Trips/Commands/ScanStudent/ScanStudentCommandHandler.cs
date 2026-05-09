using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Trips.Commands.ScanStudent;

public class ScanStudentCommandHandler
    : IRequestHandler<ScanStudentCommand, Result<ScanStudentResponse>>
{
    private readonly IApplicationDbContext _context;

    public ScanStudentCommandHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<ScanStudentResponse>> Handle(
        ScanStudentCommand request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.QrToken))
            return Result<ScanStudentResponse>.Failure("QR token is required.");

        // Trip must exist and be active.
        var trip = await _context.Trips
            .FirstOrDefaultAsync(t => t.Id == request.TripId, ct);
        if (trip is null)
            return Result<ScanStudentResponse>.Failure("Trip not found.");
        if (trip.Status == TripStatus.Completed)
            return Result<ScanStudentResponse>.Failure("Trip has already ended.");

        // Resolve the QR token to a student.
        var qr = await _context.StudentQrTokens
            .FirstOrDefaultAsync(q => q.Token == request.QrToken.Trim(), ct);
        if (qr is null || qr.StudentId is null)
            return Result<ScanStudentResponse>.Failure("Student not found for this QR.");

        var student = await _context.Students
            .FirstOrDefaultAsync(s => s.Id == qr.StudentId, ct);
        if (student is null)
            return Result<ScanStudentResponse>.Failure("Student record missing.");

        // Find or create the StudentTrip row.
        var st = await _context.StudentTrips
            .FirstOrDefaultAsync(x => x.TripId == trip.Id && x.StudentId == student.Id, ct);

        var addedToRoster = false;
        var now = DateTime.UtcNow;

        if (st is null)
        {
            st = new StudentTrip
            {
                TripId         = trip.Id,
                StudentId      = student.Id,
                BoardingStatus = BoardingStatus.Boarded,
                BoardingTime   = now,
            };
            _context.StudentTrips.Add(st);
            addedToRoster = true;
        }
        else
        {
            st.BoardingStatus = BoardingStatus.Boarded;
            st.BoardingTime   = now;
        }

        // Capture home GPS the first time we have it — subsequent scans
        // don't overwrite to keep the canonical home location stable.
        if (trip.Type == TripType.Morning
            && request.Latitude is double lat
            && request.Longitude is double lng
            && student.Latitude is null
            && student.Longitude is null)
        {
            student.Latitude  = lat;
            student.Longitude = lng;
        }

        await _context.SaveChangesAsync(ct);

        return Result<ScanStudentResponse>.Success(new ScanStudentResponse(
            student.Id, student.FullName,
            st.BoardingStatus.ToString(), now, addedToRoster));
    }
}
