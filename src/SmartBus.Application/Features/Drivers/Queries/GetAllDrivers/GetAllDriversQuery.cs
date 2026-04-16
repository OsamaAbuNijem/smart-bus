using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;

public record GetAllDriversQuery(int PageNumber = 1, int PageSize = 10) : IRequest<PagedResult<DriverDto>>;

public record DriverDto(
    Guid Id,
    string FullName,
    string PhoneNumber,
    string LicenseNumber,
    bool IsActive,
    DateTime CreatedAt
);
