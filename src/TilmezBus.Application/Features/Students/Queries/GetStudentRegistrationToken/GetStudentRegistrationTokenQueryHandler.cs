using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Queries.GetStudentRegistrationToken;

public class GetStudentRegistrationTokenQueryHandler
    : IRequestHandler<GetStudentRegistrationTokenQuery, Result<StudentRegistrationTokenInfoDto>>
{
    private readonly IApplicationDbContext _context;

    public GetStudentRegistrationTokenQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<StudentRegistrationTokenInfoDto>> Handle(
        GetStudentRegistrationTokenQuery request, CancellationToken cancellationToken)
    {
        var token = (request.Token ?? string.Empty).Trim();
        if (token.Length == 0) return Result<StudentRegistrationTokenInfoDto>.Failure("Token is required.");

        var dto = await _context.StudentQrTokens
            .Where(t => t.Token == token)
            .Select(t => new StudentRegistrationTokenInfoDto(
                t.Token,
                t.IsRegistered,
                t.SchoolId,
                t.School.Name,
                t.School.City,
                t.StudentId,
                t.Student != null ? t.Student.FullName : null,
                t.Student != null ? t.Student.Grade    : null))
            .FirstOrDefaultAsync(cancellationToken);

        return dto is not null
            ? Result<StudentRegistrationTokenInfoDto>.Success(dto)
            : Result<StudentRegistrationTokenInfoDto>.Failure("Student registration token not found.");
    }
}
