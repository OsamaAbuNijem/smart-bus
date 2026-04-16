using MediatR;
using SmartBus.Application.Common.Models;
using SmartBus.Application.Features.AbsenceRequests.Queries.GetAbsenceRequestsByStudent;

namespace SmartBus.Application.Features.AbsenceRequests.Queries.GetPendingAbsenceRequests;

public record GetPendingAbsenceRequestsQuery(int PageNumber = 1, int PageSize = 20) : IRequest<PagedResult<AbsenceRequestDto>>;
