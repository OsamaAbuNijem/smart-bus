using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Trips.Commands.ScanStudent;

/// <summary>
/// Assistant scans a student QR code on the bus. Resolves the token, marks
/// the student as Boarded on this trip (creating the StudentTrip row if the
/// student wasn't on the original roster).
/// </summary>
public record ScanStudentCommand(
    Guid TripId,
    string QrToken,
    double? Latitude = null,
    double? Longitude = null
) : IRequest<Result<ScanStudentResponse>>;

public record ScanStudentResponse(
    Guid StudentId,
    string FullName,
    string BoardingStatus,
    DateTime BoardingTime,
    bool WasAddedToRoster);
