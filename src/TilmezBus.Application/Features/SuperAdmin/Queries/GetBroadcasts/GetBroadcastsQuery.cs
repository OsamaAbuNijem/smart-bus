using MediatR;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.SuperAdmin.Queries.GetBroadcasts;

/// <summary>
/// Newest-first list of SuperAdmin broadcasts. Caps the page at 50 rows —
/// the SuperAdmin UI shows a recent-activity log, not a full archive.
/// </summary>
public record GetBroadcastsQuery(int Limit = 50) : IRequest<IReadOnlyList<BroadcastDto>>;

public record BroadcastDto(
    Guid Id,
    string Title,
    string Message,
    BroadcastTarget Target,
    string? SchoolIdsCsv,
    int Recipients,
    int Delivered,
    DateTime CreatedAt
);
