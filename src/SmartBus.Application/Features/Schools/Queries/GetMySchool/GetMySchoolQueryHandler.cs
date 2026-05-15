using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Schools.Queries.GetAllSchools;

namespace SmartBus.Application.Features.Schools.Queries.GetMySchool;

public class GetMySchoolQueryHandler : IRequestHandler<GetMySchoolQuery, Result<SchoolDto>>
{
    private readonly IApplicationDbContext _context;

    public GetMySchoolQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<SchoolDto>> Handle(GetMySchoolQuery request, CancellationToken cancellationToken)
    {
        var school = await _context.Schools
            .Where(s => !s.IsDeleted && s.AdminEmail == request.AdminEmail)
            .Select(s => new SchoolDto(s.Id, s.Name, s.City, s.ContactEmail, s.PhoneNumber,
                s.AdminEmail, s.Notes, s.CreatedAt))
            .FirstOrDefaultAsync(cancellationToken);

        return school is not null
            ? Result<SchoolDto>.Success(school)
            : Result<SchoolDto>.Failure("School not found for this admin.");
    }
}
