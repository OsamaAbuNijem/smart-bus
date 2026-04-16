using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Commands.DeleteDriver;

public class DeleteDriverCommandHandler : IRequestHandler<DeleteDriverCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public DeleteDriverCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(DeleteDriverCommand request, CancellationToken cancellationToken)
    {
        var driver = await _unitOfWork.Drivers.GetByIdAsync(request.DriverId, cancellationToken);
        if (driver is null) return Result.Failure("Driver not found.");

        await _unitOfWork.Drivers.DeleteAsync(driver);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
