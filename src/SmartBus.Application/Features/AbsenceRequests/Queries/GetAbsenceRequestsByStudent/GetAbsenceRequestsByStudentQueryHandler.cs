using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.AbsenceRequests.Queries.GetAbsenceRequestsByStudent;

public class GetAbsenceRequestsByStudentQueryHandler : IRequestHandler<GetAbsenceRequestsByStudentQuery, Result<IReadOnlyList<AbsenceRequestDto>>>
{
    private readonly IApplicationDbContext _context;

    public GetAbsenceRequestsByStudentQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<Result<IReadOnlyList<AbsenceRequestDto>>> Handle(GetAbsenceRequestsByStudentQuery request, CancellationToken cancellationToken)
    {
        var items = await _context.AbsenceRequests
            .Where(a => a.StudentId == request.StudentId && !a.IsDeleted)
            .Include(a => a.Student)
            .OrderByDescending(a => a.Date)
            .Select(a => new AbsenceRequestDto(a.Id, a.StudentId, a.Student.FullName, a.Date, a.TripType, a.Reason, a.Status, a.CreatedAt))
            .ToListAsync(cancellationToken);

        return Result<IReadOnlyList<AbsenceRequestDto>>.Success(items);
    }
}
