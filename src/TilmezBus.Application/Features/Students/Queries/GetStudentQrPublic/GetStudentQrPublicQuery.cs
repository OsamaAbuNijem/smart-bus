using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Queries.GetStudentQrPublic;

/// <summary>
/// Resolves a student QR token to a public-facing "lost-and-found" card:
/// student identity + the school and parent contact info the finder
/// needs to reunite the kid. No authentication required — designed to
/// be opened by anyone who scans the QR with their phone camera.
/// </summary>
public record GetStudentQrPublicQuery(string Token)
    : IRequest<Result<PublicStudentQrDto>>;

public record PublicStudentQrDto(
    string StudentName,
    string? StudentNameEn,
    string Grade,
    string? ParentName,
    string? ParentPhone,
    string SchoolName,
    string? SchoolPhone,
    string? SchoolLogoUrl,
    string? City);
