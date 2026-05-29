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
    string? PhoneNumber,
    // SuperAdmin-controlled feature flags from the school's currently
    // active subscription. The mobile app uses these to hide QR / NFC
    // entry points when the school's plan doesn't include them.
    // Default to true when no active subscription is present so we
    // don't accidentally lock the assistant out of every scan flow.
    bool EnableQr,
    bool EnableNfc);
