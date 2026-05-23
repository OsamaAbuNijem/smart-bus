using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Schools.Queries.GetMyFleetSchoolInfo;

/// <summary>
/// Lightweight school info for a driver / assistant — name, city, phone.
/// Used by the mobile settings screen's "School info" section so the
/// crew member can see who they're driving for without the full
/// admin-only /schools/current payload (subscription block, etc.).
/// </summary>
public record GetMyFleetSchoolInfoQuery(string UserId)
    : IRequest<Result<SchoolInfoDto?>>;

public record SchoolInfoDto(
    string Name,
    string? City,
    string? PhoneNumber);
