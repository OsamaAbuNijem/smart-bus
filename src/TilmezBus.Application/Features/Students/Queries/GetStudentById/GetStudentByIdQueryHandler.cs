using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Queries.GetStudentById;

public class GetStudentByIdQueryHandler : IRequestHandler<GetStudentByIdQuery, Result<StudentDetailDto>>
{
    private readonly IApplicationDbContext _context;

    public GetStudentByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<StudentDetailDto>> Handle(GetStudentByIdQuery request, CancellationToken cancellationToken)
    {
        var student = await _context.Students
            .Where(s => s.Id == request.StudentId && !s.IsDeleted)
            .Include(s => s.Parent)
            .FirstOrDefaultAsync(cancellationToken);

        if (student is null) return Result<StudentDetailDto>.Failure("Student not found.");

        var dto = new StudentDetailDto(
            student.Id,
            student.FullName,
            student.FullNameEn,
            student.NationalNumber,
            student.Grade,
            student.Class,
            student.DateOfBirth,
            student.Address,
            student.Parent?.FullName    ?? string.Empty,
            student.Parent?.PhoneNumber ?? string.Empty,
            RouteName: null,
            student.Latitude,
            student.Longitude,
            student.HomeArea,
            student.HomeStreet,
            student.HomeBuildingNumber,
            student.CreatedAt);

        return Result<StudentDetailDto>.Success(dto);
    }
}
