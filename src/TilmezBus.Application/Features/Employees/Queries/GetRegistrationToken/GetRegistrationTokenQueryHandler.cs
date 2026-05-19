using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Employees.Queries.GetRegistrationToken;

public class GetRegistrationTokenQueryHandler
    : IRequestHandler<GetRegistrationTokenQuery, Result<RegistrationTokenInfoDto>>
{
    private readonly IApplicationDbContext _context;

    public GetRegistrationTokenQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<RegistrationTokenInfoDto>> Handle(
        GetRegistrationTokenQuery request, CancellationToken cancellationToken)
    {
        var token = (request.Token ?? string.Empty).Trim();
        if (token.Length == 0) return Result<RegistrationTokenInfoDto>.Failure("Token is required.");

        var dto = await _context.EmployeeQrTokens
            .Where(t => t.Token == token)
            .Select(t => new RegistrationTokenInfoDto(
                t.Token,
                t.Type.ToString(),
                t.IsUsed,
                t.SchoolId,
                t.School.Name,
                t.School.City))
            .FirstOrDefaultAsync(cancellationToken);

        return dto is not null
            ? Result<RegistrationTokenInfoDto>.Success(dto)
            : Result<RegistrationTokenInfoDto>.Failure("Registration token not found.");
    }
}
