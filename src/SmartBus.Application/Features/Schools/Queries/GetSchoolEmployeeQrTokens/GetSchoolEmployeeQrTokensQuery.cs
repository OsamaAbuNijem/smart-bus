using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Schools.Queries.GetSchoolEmployeeQrTokens;

/// <summary>SuperAdmin: list all employee-registration QR tokens for a school.</summary>
public record GetSchoolEmployeeQrTokensQuery(Guid SchoolId) : IRequest<Result<SchoolEmployeeQrTokensDto>>;

public record SchoolEmployeeQrTokensDto(
    Guid SchoolId,
    string SchoolName,
    IReadOnlyList<EmployeeQrTokenDto> Drivers,
    IReadOnlyList<EmployeeQrTokenDto> Assistants
);

public record EmployeeQrTokenDto(
    Guid Id,
    string Token,
    string Type,
    bool IsUsed,
    DateTime? UsedAt,
    string? UsedFullName,
    string? UsedPhoneNumber,
    DateTime CreatedAt
);
