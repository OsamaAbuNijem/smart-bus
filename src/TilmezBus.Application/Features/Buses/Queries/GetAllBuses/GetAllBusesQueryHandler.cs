using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Buses.Queries.GetAllBuses;

public class GetAllBusesQueryHandler : IRequestHandler<GetAllBusesQuery, PagedResult<BusDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllBusesQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PagedResult<BusDto>> Handle(GetAllBusesQuery request, CancellationToken cancellationToken)
    {
        var baseQuery = _context.Buses
            .Where(b => !b.IsDeleted)
            .Include(b => b.LastLocation)
            .AsQueryable();

        // Tenant scope: when the caller passes a SchoolId, restrict to that
        // school. SuperAdmin call sites that legitimately want cross-school
        // results pass null.
        if (request.SchoolId.HasValue)
            baseQuery = baseQuery.Where(b => b.SchoolId == request.SchoolId.Value);

        // Plate-number filter (substring, case-insensitive).
        if (!string.IsNullOrWhiteSpace(request.PlateNumber))
        {
            var plate = request.PlateNumber.Trim();
            baseQuery = baseQuery.Where(b => EF.Functions.Like(b.PlateNumber, $"%{plate}%"));
        }

        // PersonName filter previously matched any of the 4 BusSchedule
        // driver/assistant slots. Schedules were removed; the filter now
        // returns no results to keep the existing search box from
        // crashing the call. Admin web hides this filter going forward.
        if (!string.IsNullOrWhiteSpace(request.PersonName))
        {
            baseQuery = baseQuery.Where(_ => false);
        }

        var totalCount = await baseQuery.CountAsync(cancellationToken);

        var busEntities = await baseQuery
            // Bus numbers are BUS-#### so a lexicographic sort matches the
            // visual numeric order (zero-padded).
            .OrderBy(b => b.PlateNumber)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        // BusSchedule columns are gone — driver/assistant + roster are now
        // populated per trip, not per bus. The DTO fields stay null/empty.
        var buses = busEntities.Select(b => new BusDto(
            b.Id, b.PlateNumber, b.Capacity, b.Status.ToString(),
            DriverName:          null,
            AssistantDriverName: null,
            StudentCount: 0,
            StudentIds:   Array.Empty<Guid>(),
            b.LastLocation?.Latitude, b.LastLocation?.Longitude,
            b.CreatedAt,
            IsScheduleComplete: false,
            b.QrToken)).ToList();

        return PagedResult<BusDto>.Create(buses, totalCount, request.PageNumber, request.PageSize);
    }
}
