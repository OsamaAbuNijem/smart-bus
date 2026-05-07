using MediatR;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Queries.GetBusByQrToken;

public record GetBusByQrTokenQuery(string QrToken)
    : IRequest<Result<BusSummaryDto>>;

public record BusSummaryDto(
    Guid Id,
    string PlateNumber,
    string? Model,
    int Capacity);
