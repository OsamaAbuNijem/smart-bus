using MediatR;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Buses.Queries.GetBusByQrToken;

public record GetBusByQrTokenQuery(string QrToken)
    : IRequest<Result<BusSummaryDto>>;

public record BusSummaryDto(
    Guid Id,
    string PlateNumber,
    string? Model,
    int Capacity);
