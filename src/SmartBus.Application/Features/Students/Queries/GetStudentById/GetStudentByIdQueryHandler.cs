using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Queries.GetStudentById;

public class GetStudentByIdQueryHandler : IRequestHandler<GetStudentByIdQuery, Result<StudentDetailDto>>
{
    private readonly IApplicationDbContext _context;

    public GetStudentByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<StudentDetailDto>> Handle(GetStudentByIdQuery request, CancellationToken cancellationToken)
    {
        var student = await _context.Students
            .Where(s => s.Id == request.StudentId && !s.IsDeleted)
            .Include(s => s.Route)
            .Include(s => s.Parent)
            .Include(s => s.Allergies)
            .Include(s => s.EmergencyContacts)
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
            student.Route?.Name,
            student.Latitude,
            student.Longitude,
            student.HomeArea,
            student.HomeStreet,
            student.HomeBuildingNumber,
            student.Allergies.Select(a => a.Condition).ToList(),
            student.EmergencyContacts.Select(e => new EmergencyContactDto(e.Id, e.Name, e.PhoneNumber, e.Relation)).ToList(),
            student.CreatedAt);

        return Result<StudentDetailDto>.Success(dto);
    }
}
