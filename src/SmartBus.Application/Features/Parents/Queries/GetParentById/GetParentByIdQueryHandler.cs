using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.Students.Queries.GetAllStudents;

namespace SmartBus.Application.Features.Parents.Queries.GetParentById;

public class GetParentByIdQueryHandler : IRequestHandler<GetParentByIdQuery, Result<ParentDetailDto>>
{
    private readonly IApplicationDbContext _context;

    public GetParentByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<ParentDetailDto>> Handle(GetParentByIdQuery request, CancellationToken cancellationToken)
    {
        var parent = await _context.Parents
            .Where(p => p.Id == request.ParentId && !p.IsDeleted)
            .Include(p => p.Children.Where(c => !c.IsDeleted))
            .ThenInclude(c => c.Route)
            .FirstOrDefaultAsync(cancellationToken);

        if (parent is null) return Result<ParentDetailDto>.Failure("Parent not found.");

        var dto = new ParentDetailDto(
            parent.Id, parent.FullName, parent.PhoneNumber,
            parent.Children.Select(c => new StudentDto(
                c.Id, c.FullName, c.FullNameEn, c.NationalNumber, c.Grade, c.Class,
                parent.FullName, parent.PhoneNumber,
                c.Route?.Name,
                c.Latitude, c.Longitude, c.HomeArea, c.HomeStreet, c.HomeBuildingNumber,
                c.CreatedAt)).ToList(),
            parent.CreatedAt);

        return Result<ParentDetailDto>.Success(dto);
    }
}
