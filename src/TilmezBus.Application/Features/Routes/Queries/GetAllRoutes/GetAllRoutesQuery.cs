using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Routes.Queries.GetAllRoutes;

public record GetAllRoutesQuery(int PageNumber = 1, int PageSize = 10) : IRequest<PagedResult<RouteDto>>;

public record RouteDto(Guid Id, string Name, string Description, int StopCount, DateTime CreatedAt);
