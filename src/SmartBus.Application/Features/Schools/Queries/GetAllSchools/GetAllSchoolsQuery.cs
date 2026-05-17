using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Schools.Queries.GetAllSchools;

/// <summary>
/// SuperAdmin schools grid. Filters are all optional and server-side so
/// they narrow across the full result set (not just the current page).
/// </summary>
public record GetAllSchoolsQuery(
    int PageNumber = 1,
    int PageSize   = 10,
    string? Name   = null,
    string? City   = null,
    SubscriptionType?    Plan   = null,
    SchoolStatusFilter?  Status = null
) : IRequest<PagedResult<SchoolDto>>;

/// <summary>
/// 2-state filter for "what's the last subscription's status":
///   * Active   — IsActive AND today ∈ [activation, expiration]
///   * Inactive — everything else (disabled, expired, future, or no sub)
/// </summary>
public enum SchoolStatusFilter
{
    Active   = 0,
    Inactive = 1
}

public record SchoolDto(
    Guid Id,
    string Name,
    string City,
    string PhoneNumber,
    string AdminEmail,
    string? ContactName,
    double? Latitude,
    double? Longitude,
    string? LogoUrl,
    DateTime CreatedAt,
    // The school's most-recent Subscription (regardless of state). Null when
    // no sub has ever been created. The client computes a 4-state status pill
    // (live/expired/future/disabled) from IsActive + the two date bounds.
    DateTime? LastSubscriptionActivationDate,
    DateTime? LastSubscriptionExpirationDate,
    SubscriptionType? LastSubscriptionType,
    bool?     LastSubscriptionIsActive,
    // Plan details surfaced on the admin Settings page. Null when the
    // school has no subscription yet.
    int?      LastSubscriptionMaxStudents = null,
    int?      LastSubscriptionMaxBuses    = null,
    decimal?  LastSubscriptionPrice       = null
);
