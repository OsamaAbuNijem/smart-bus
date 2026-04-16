using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Routes.Commands.CreateRoute;

public class CreateRouteCommandHandler : IRequestHandler<CreateRouteCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateRouteCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(CreateRouteCommand request, CancellationToken cancellationToken)
    {
        var route = new Route
        {
            Name = request.Name,
            Description = request.Description ?? string.Empty,
            StartLatitude = request.StartLatitude,
            StartLongitude = request.StartLongitude,
            EndLatitude = request.EndLatitude,
            EndLongitude = request.EndLongitude,
            Stops = request.Stops.Select(s => new Stop
            {
                Name = s.Name,
                Latitude = s.Latitude,
                Longitude = s.Longitude,
                Order = s.Order
            }).ToList()
        };

        await _unitOfWork.Routes.AddAsync(route, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(route.Id);
    }
}
