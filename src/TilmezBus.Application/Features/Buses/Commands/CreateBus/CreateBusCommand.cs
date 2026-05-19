using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Buses.Commands.CreateBus;

public record CreateBusCommand(
    string PlateNumber,
    int Capacity,
    string Status
) : IRequest<Result<Guid>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "buses:page:*" };
}
