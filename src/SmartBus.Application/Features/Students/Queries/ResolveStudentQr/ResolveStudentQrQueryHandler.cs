using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Queries.ResolveStudentQr;

public class ResolveStudentQrQueryHandler
    : IRequestHandler<ResolveStudentQrQuery, Result<ResolveStudentQrResponse>>
{
    private readonly IApplicationDbContext _context;

    public ResolveStudentQrQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<Result<ResolveStudentQrResponse>> Handle(
        ResolveStudentQrQuery request, CancellationToken cancellationToken)
    {
        var token = (request.Token ?? string.Empty).Trim();
        if (token.Length == 0)
            return Result<ResolveStudentQrResponse>.Failure("QR token is required.");

        var qr = await _context.StudentQrTokens
            .FirstOrDefaultAsync(t => t.Token == token, cancellationToken);
        if (qr is null)
            return Result<ResolveStudentQrResponse>.Failure("Student QR not found.");
        if (!qr.IsRegistered || qr.StudentId is null)
            return Result<ResolveStudentQrResponse>.Failure(
                "This QR is not linked to a student yet.");

        var student = await _context.Students
            .Where(s => s.Id == qr.StudentId.Value && !s.IsDeleted)
            .Select(s => new ResolveStudentQrResponse(
                s.Id.ToString(),
                s.FullName,
                s.FullNameEn,
                s.Grade))
            .FirstOrDefaultAsync(cancellationToken);

        return student is not null
            ? Result<ResolveStudentQrResponse>.Success(student)
            : Result<ResolveStudentQrResponse>.Failure("Student not found.");
    }
}
