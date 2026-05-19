using MediatR;
using TilmezBus.Application.Common.Caching;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Drivers.Commands.CreateDriver;

public record CreateDriverCommand(
    string FullName,
    string? FullNameEn,
    string PhoneNumber,
    bool IsActive = true,
    DriverType DriverType = DriverType.Driver,
    Guid? SchoolId = null
) : IRequest<Result<Guid>>, ICacheInvalidator
{
    public IEnumerable<string> CachePatternsToInvalidate => new[] { "drivers:page:*" };
}
