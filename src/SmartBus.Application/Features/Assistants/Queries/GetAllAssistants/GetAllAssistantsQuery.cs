using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Assistants.Queries.GetAllAssistants;

public record GetAllAssistantsQuery(int PageNumber = 1, int PageSize = 10) : IRequest<PagedResult<AssistantDto>>;

public record AssistantDto(Guid Id, string FullName, string PhoneNumber, DateTime CreatedAt);
