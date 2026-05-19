using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Buses.Commands.CreateBusesBatch;

/// <summary>
/// Mints <paramref name="Count"/> new buses in one call. Each row is created
/// with an auto-generated BUS-#### number (next free serial across all
/// buses), <see cref="TilmezBus.Domain.Enums.BusStatus.Active"/>, a fresh
/// per-bus QR token, and the default capacity. The admin's bulk-add modal
/// is the only caller — single-bus creation has its own command.
/// </summary>
public record CreateBusesBatchCommand(int Count, Guid SchoolId)
    : IRequest<Result<int>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "buses:page:*" };
}
