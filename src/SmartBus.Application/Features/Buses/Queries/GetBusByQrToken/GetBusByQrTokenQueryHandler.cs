using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Buses.Queries.GetBusByQrToken;

public class GetBusByQrTokenQueryHandler
    : IRequestHandler<GetBusByQrTokenQuery, Result<BusSummaryDto>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetBusByQrTokenQueryHandler(IUnitOfWork unitOfWork)
        => _unitOfWork = unitOfWork;

    public async Task<Result<BusSummaryDto>> Handle(
        GetBusByQrTokenQuery request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.QrToken))
            return Result<BusSummaryDto>.Failure("QR token is required.");

        var bus = await _unitOfWork.Buses.GetByQrTokenAsync(request.QrToken.Trim(), ct);
        if (bus is null)
            return Result<BusSummaryDto>.Failure("Bus not found for the scanned QR.");

        return Result<BusSummaryDto>.Success(
            new BusSummaryDto(bus.Id, bus.PlateNumber, bus.Model, bus.Capacity));
    }
}
