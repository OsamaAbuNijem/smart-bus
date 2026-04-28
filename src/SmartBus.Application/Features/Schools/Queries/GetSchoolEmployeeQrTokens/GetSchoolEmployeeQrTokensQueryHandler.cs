using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Schools.Queries.GetSchoolEmployeeQrTokens;

public class GetSchoolEmployeeQrTokensQueryHandler
    : IRequestHandler<GetSchoolEmployeeQrTokensQuery, Result<SchoolEmployeeQrTokensDto>>
{
    private readonly IApplicationDbContext _context;

    public GetSchoolEmployeeQrTokensQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<SchoolEmployeeQrTokensDto>> Handle(
        GetSchoolEmployeeQrTokensQuery request, CancellationToken ct)
    {
        var school = await _context.Schools
            .Where(s => s.Id == request.SchoolId)
            .Select(s => new { s.Id, s.Name })
            .FirstOrDefaultAsync(ct);
        if (school is null) return Result<SchoolEmployeeQrTokensDto>.Failure("School not found.");

        var rows = await _context.EmployeeQrTokens
            .Where(t => t.SchoolId == request.SchoolId)
            .OrderBy(t => t.Type).ThenBy(t => t.CreatedAt)
            .ToListAsync(ct);

        // Resolve consumed-employee names cheaply via two batch queries.
        var driverIds    = rows.Where(r => r.UsedDriverId    is not null).Select(r => r.UsedDriverId!.Value).Distinct().ToList();
        var assistantIds = rows.Where(r => r.UsedAssistantId is not null).Select(r => r.UsedAssistantId!.Value).Distinct().ToList();
        var driverMap    = await _context.Drivers
            .Where(d => driverIds.Contains(d.Id))
            .Select(d => new { d.Id, d.FullName, d.PhoneNumber })
            .ToDictionaryAsync(d => d.Id, ct);
        var assistantMap = await _context.Assistants
            .Where(a => assistantIds.Contains(a.Id))
            .Select(a => new { a.Id, a.FullName, a.PhoneNumber })
            .ToDictionaryAsync(a => a.Id, ct);

        EmployeeQrTokenDto Map(Domain.Entities.EmployeeQrToken t)
        {
            string? name = null, phone = null;
            if (t.UsedDriverId is not null && driverMap.TryGetValue(t.UsedDriverId.Value, out var d))
                { name = d.FullName; phone = d.PhoneNumber; }
            else if (t.UsedAssistantId is not null && assistantMap.TryGetValue(t.UsedAssistantId.Value, out var a))
                { name = a.FullName; phone = a.PhoneNumber; }

            return new EmployeeQrTokenDto(
                t.Id, t.Token, t.Type.ToString(), t.IsUsed, t.UsedAt, name, phone, t.CreatedAt);
        }

        var drivers    = rows.Where(t => t.Type == EmployeeQrTokenType.Driver).Select(Map).ToList();
        var assistants = rows.Where(t => t.Type == EmployeeQrTokenType.Assistant).Select(Map).ToList();

        return Result<SchoolEmployeeQrTokensDto>.Success(
            new SchoolEmployeeQrTokensDto(school.Id, school.Name, drivers, assistants));
    }
}
