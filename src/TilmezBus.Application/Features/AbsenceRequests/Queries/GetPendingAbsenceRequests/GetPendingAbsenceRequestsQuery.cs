using MediatR;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Features.AbsenceRequests.Queries.GetAbsenceRequestsByStudent;

namespace TilmezBus.Application.Features.AbsenceRequests.Queries.GetPendingAbsenceRequests;

public record GetPendingAbsenceRequestsQuery(int PageNumber = 1, int PageSize = 20) : IRequest<PagedResult<AbsenceRequestDto>>;
