using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Commands.RegisterFromQr;

/// <summary>
/// Parent (authenticated) scans a student QR for the first time and submits
/// the child's details. We create the Student row, link it to the caller's
/// Parent record, and bind the token to the new Student so subsequent
/// driver/assistant scans resolve to it.
/// </summary>
public record RegisterStudentFromQrCommand(
    string Token,
    string FullName,
    string Grade,
    string? Class,
    string? NationalNumber,
    string? HomeArea,
    string? HomeStreet,
    string? HomeBuildingNumber,
    double? Latitude,
    double? Longitude
) : IRequest<Result<RegisterStudentFromQrResponse>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "students:page:*" };
}

public record RegisterStudentFromQrResponse(
    Guid StudentId,
    string Token,
    string FullName,
    string Grade,
    Guid SchoolId,
    string SchoolName
);
