using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.AbsenceRequests.Queries.GetAbsenceRequestsByStudent;
using TilmezBus.Domain.Enums;

namespace TilmezBus.Application.Features.AbsenceRequests.Queries.GetPendingAbsenceRequests;

public class GetPendingAbsenceRequestsQueryHandler : IRequestHandler<GetPendingAbsenceRequestsQuery, PagedResult<AbsenceRequestDto>>
{
    private readonly IApplicationDbContext _context;

    public GetPendingAbsenceRequestsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<AbsenceRequestDto>> Handle(GetPendingAbsenceRequestsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.AbsenceRequests
            .Where(a => a.Status == AbsenceRequestStatus.Pending && !a.IsDeleted)
            .Include(a => a.Student);

        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .OrderBy(a => a.Date)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            // Admin pending-list doesn't need the parent-side CanCancel
            // flag — always set false here.
            .Select(a => new AbsenceRequestDto(a.Id, a.StudentId, a.Student.FullName, a.Date, a.TripType, a.Reason, a.Status, a.CreatedAt, false))
            .ToListAsync(cancellationToken);

        return PagedResult<AbsenceRequestDto>.Create(items, total, request.PageNumber, request.PageSize);
    }
}
