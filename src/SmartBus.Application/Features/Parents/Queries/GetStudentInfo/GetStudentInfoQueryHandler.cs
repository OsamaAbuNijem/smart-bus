using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Parents.Queries.GetStudentInfo;

public class GetStudentInfoQueryHandler
    : IRequestHandler<GetStudentInfoQuery, Result<StudentInfoDto>>
{
    private readonly IApplicationDbContext _db;
    public GetStudentInfoQueryHandler(IApplicationDbContext db) => _db = db;

    public async Task<Result<StudentInfoDto>> Handle(
        GetStudentInfoQuery request, CancellationToken ct)
    {
        var data = await _db.Students
            .Where(s => s.Id == request.StudentId && s.ParentId == request.ParentId)
            .Include(s => s.Route)
            .Include(s => s.PickupStop)
            .Include(s => s.Allergies)
            .Include(s => s.Parent)
            .Select(s => new
            {
                Student = s,
                AllergyNames = s.Allergies.Select(a => a.Condition).ToList(),
                Parent = s.Parent == null
                    ? null
                    : new StudentContactDto(
                        s.Parent.Id,
                        s.Parent.FullName,
                        s.Parent.PhoneNumber,
                        "Parent",
                        null),
            })
            .FirstOrDefaultAsync(ct);

        if (data is null)
            return Result<StudentInfoDto>.Failure(
                "الطالب غير موجود لهذا الولي.");

        var s = data.Student;

        // SchoolId is a string column; try to resolve the School name + the
        // single-line City we expose as the school address.
        string? schoolName = null;
        string? schoolAddress = null;
        if (Guid.TryParse(s.SchoolId, out var schoolGuid))
        {
            var school = await _db.Schools
                .Where(sc => sc.Id == schoolGuid)
                .Select(sc => new { sc.Name, sc.City })
                .FirstOrDefaultAsync(ct);
            schoolName = school?.Name;
            schoolAddress = string.IsNullOrWhiteSpace(school?.City)
                ? null
                : school!.City;
        }

        // Compose a single human-readable address line.
        var addressParts = new[]
        {
            s.HomeStreet,
            s.HomeBuildingNumber,
            s.HomeArea,
        }.Where(p => !string.IsNullOrWhiteSpace(p)).ToList();
        var homeAddress = addressParts.Count > 0
            ? string.Join(", ", addressParts)
            : (s.Address ?? string.Empty);

        return Result<StudentInfoDto>.Success(new StudentInfoDto(
            Id: s.Id,
            FullName: s.FullName,
            FullNameEn: s.FullNameEn,
            NationalNumber: s.NationalNumber,
            Grade: s.Grade,
            Class: s.Class,
            DateOfBirth: s.DateOfBirth,
            SchoolName: schoolName,
            SchoolAddress: schoolAddress,
            HomeAddress: homeAddress,
            HomeArea: s.HomeArea,
            HomeStreet: s.HomeStreet,
            Notes: s.Address, // re-use Address as freeform notes when used
            RouteName: s.Route != null ? s.Route.Name : null,
            PickupStopName: s.PickupStop != null ? s.PickupStop.Name : null,
            Allergies: data.AllergyNames,
            Parent: data.Parent));
    }
}
