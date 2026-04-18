using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Drivers.Queries.GetAllDrivers;

public record GetAllDriversQuery(
    int PageNumber = 1,
    int PageSize = 10,
    DriverType? DriverType = null
) : IRequest<PagedResult<DriverDto>>;

public record DriverDto(
    Guid Id,
    string FullName,
    string? FullNameEn,
    string PhoneNumber,
    string LicenseNumber,
    bool IsActive,
    DriverType DriverType,
    DateTime CreatedAt
);
