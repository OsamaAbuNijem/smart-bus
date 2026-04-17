using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Commands.UpdateDriver;

public class UpdateDriverCommandHandler : IRequestHandler<UpdateDriverCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateDriverCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(UpdateDriverCommand request, CancellationToken cancellationToken)
    {
        var driver = await _unitOfWork.Drivers.GetByIdAsync(request.DriverId, cancellationToken);
        if (driver is null) return Result.Failure("Driver not found.");

        var existing = await _unitOfWork.Drivers.GetByLicenseNumberAsync(request.LicenseNumber, cancellationToken);
        if (existing is not null && existing.Id != request.DriverId)
            return Result.Failure($"License number '{request.LicenseNumber}' is already used by another driver.");

        driver.FullName = request.FullName;
        driver.PhoneNumber = request.PhoneNumber;
        driver.LicenseNumber = request.LicenseNumber;
        driver.IsActive = request.IsActive;

        await _unitOfWork.Drivers.UpdateAsync(driver);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
