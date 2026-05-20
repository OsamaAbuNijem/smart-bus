using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.Schools.Queries.GetSchoolEmployeeQrTokens;

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

        // Drivers and Assistants both live in the Drivers table now —
        // UsedDriverId and UsedAssistantId both reference Drivers.Id.
        var employeeIds = rows
            .SelectMany(r => new[] { r.UsedDriverId, r.UsedAssistantId })
            .Where(id => id is not null)
            .Select(id => id!.Value)
            .Distinct()
            .ToList();
        var employeeMap = await _context.Drivers
            .Where(d => employeeIds.Contains(d.Id))
            .Select(d => new { d.Id, d.FullName, d.PhoneNumber })
            .ToDictionaryAsync(d => d.Id, ct);

        EmployeeQrTokenDto Map(Domain.Entities.EmployeeQrToken t)
        {
            string? name = null, phone = null;
            var employeeId = t.UsedDriverId ?? t.UsedAssistantId;
            if (employeeId is not null && employeeMap.TryGetValue(employeeId.Value, out var e))
                { name = e.FullName; phone = e.PhoneNumber; }

            return new EmployeeQrTokenDto(
                t.Id, t.Token, t.Type.ToString(), t.IsUsed, t.UsedAt, name, phone, t.CreatedAt);
        }

        var drivers    = rows.Where(t => t.Type == EmployeeQrTokenType.Driver).Select(Map).ToList();
        var assistants = rows.Where(t => t.Type == EmployeeQrTokenType.Assistant).Select(Map).ToList();

        return Result<SchoolEmployeeQrTokensDto>.Success(
            new SchoolEmployeeQrTokensDto(school.Id, school.Name, drivers, assistants));
    }
}
