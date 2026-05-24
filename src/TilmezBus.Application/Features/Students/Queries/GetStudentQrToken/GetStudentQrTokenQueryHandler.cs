using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Queries.GetStudentQrToken;

public class GetStudentQrTokenQueryHandler
    : IRequestHandler<GetStudentQrTokenQuery, Result<string?>>
{
    private readonly IApplicationDbContext _context;

    public GetStudentQrTokenQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<string?>> Handle(
        GetStudentQrTokenQuery request, CancellationToken ct)
    {
        var token = await _context.StudentQrTokens
            .Where(t => t.StudentId == request.StudentId
                     && t.IsRegistered)
            .Select(t => t.Token)
            .FirstOrDefaultAsync(ct);
        return Result<string?>.Success(token);
    }
}
