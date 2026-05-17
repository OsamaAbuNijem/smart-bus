using MediatR;
using SmartBus.Application.Common.Caching;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Commands.CreateBusesBatch;

/// <summary>
/// Mints <paramref name="Count"/> new buses in one call. Each row is created
/// with an auto-generated BUS-#### number (next free serial across all
/// buses), <see cref="SmartBus.Domain.Enums.BusStatus.Active"/>, a fresh
/// per-bus QR token, and the default capacity. The admin's bulk-add modal
/// is the only caller — single-bus creation has its own command.
/// </summary>
public record CreateBusesBatchCommand(int Count, Guid SchoolId)
    : IRequest<Result<int>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "buses:page:*" };
}
