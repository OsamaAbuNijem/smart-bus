using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.DemoRequests.Queries.GetAllDemoRequests;

/// <summary>
/// SuperAdmin's paginated demo-request queue. Status is optional — when
/// null, returns all (pending + completed) newest-first.
/// </summary>
public record GetAllDemoRequestsQuery(
    int PageNumber = 1,
    int PageSize   = 20,
    DemoRequestStatus? Status = null
) : IRequest<PagedResult<DemoRequestDto>>;

public record DemoRequestDto(
    Guid     Id,
    string   SchoolName,
    string   ContactName,
    string   Email,
    string?  PhoneNumber,
    string?  Notes,
    DemoRequestStatus Status,
    DateTime CreatedAt,
    DateTime? CompletedAt);
