using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.Schools.Queries.GetAllSchools;

namespace TilmezBus.Application.Features.Schools.Queries.GetMySchool;

public class GetMySchoolQueryHandler : IRequestHandler<GetMySchoolQuery, Result<SchoolDto>>
{
    private readonly IApplicationDbContext _context;

    public GetMySchoolQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<SchoolDto>> Handle(GetMySchoolQuery request, CancellationToken cancellationToken)
    {
        // Mirror GetAllSchools: project each school alongside its newest-by-
        // activation subscription so the admin Settings page can show the
        // current plan + dates without a second round-trip.
        var school = await _context.Schools
            .Where(s => !s.IsDeleted && s.AdminEmail == request.AdminEmail)
            .Select(s => new
            {
                School = s,
                LastSub = _context.Subscriptions
                    .Where(sub => sub.SchoolId == s.Id && !sub.IsDeleted)
                    .OrderByDescending(sub => sub.ActivationDate)
                    .Select(sub => new
                    {
                        sub.SubscriptionType,
                        sub.ActivationDate,
                        sub.ExpirationDate,
                        sub.IsActive,
                        sub.MaxStudents,
                        sub.MaxBuses,
                        sub.Price
                    })
                    .FirstOrDefault()
            })
            .Select(x => new SchoolDto(
                x.School.Id, x.School.Name, x.School.City,
                x.School.PhoneNumber, x.School.AdminEmail, x.School.ContactName,
                x.School.Latitude, x.School.Longitude, x.School.LogoUrl,
                x.School.CreatedAt,
                x.LastSub != null ? (DateTime?)x.LastSub.ActivationDate : null,
                x.LastSub != null ? (DateTime?)x.LastSub.ExpirationDate : null,
                x.LastSub != null ? (TilmezBus.Domain.Enums.SubscriptionType?)x.LastSub.SubscriptionType : null,
                x.LastSub != null ? (bool?)x.LastSub.IsActive : null,
                x.LastSub != null ? (int?)x.LastSub.MaxStudents : null,
                x.LastSub != null ? (int?)x.LastSub.MaxBuses : null,
                x.LastSub != null ? (decimal?)x.LastSub.Price : null))
            .FirstOrDefaultAsync(cancellationToken);

        return school is not null
            ? Result<SchoolDto>.Success(school)
            : Result<SchoolDto>.Failure("School not found for this admin.");
    }
}
