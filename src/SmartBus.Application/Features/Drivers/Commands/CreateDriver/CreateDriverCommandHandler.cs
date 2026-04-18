using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Drivers.Commands.CreateDriver;

public class CreateDriverCommandHandler : IRequestHandler<CreateDriverCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateDriverCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(CreateDriverCommand request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.Drivers.GetByLicenseNumberAsync(request.LicenseNumber, cancellationToken);
        if (existing is not null)
            return Result<Guid>.Failure($"Driver with license '{request.LicenseNumber}' already exists.");

        var driver = new Driver
        {
            FullName      = request.FullName,
            FullNameEn    = request.FullNameEn,
            PhoneNumber   = request.PhoneNumber,
            LicenseNumber = request.LicenseNumber,
            IsActive      = request.IsActive,
            DriverType    = request.DriverType
        };

        await _unitOfWork.Drivers.AddAsync(driver, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(driver.Id);
    }
}
