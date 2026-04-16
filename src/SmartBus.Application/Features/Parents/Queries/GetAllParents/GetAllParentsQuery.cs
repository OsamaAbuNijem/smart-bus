using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Parents.Queries.GetAllParents;

public record GetAllParentsQuery(int PageNumber = 1, int PageSize = 10) : IRequest<PagedResult<ParentDto>>;

public record ParentDto(Guid Id, string FullName, string PhoneNumber, int ChildrenCount, DateTime CreatedAt);
