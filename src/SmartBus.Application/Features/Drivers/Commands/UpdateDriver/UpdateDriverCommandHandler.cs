using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Drivers.Commands.UpdateDriver;

public class UpdateDriverCommandHandler : IRequestHandler<UpdateDriverCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public UpdateDriverCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    { _unitOfWork = unitOfWork; _context = context; }

    public async Task<Result> Handle(UpdateDriverCommand request, CancellationToken cancellationToken)
    {
        var driver = await _unitOfWork.Drivers.GetByIdAsync(request.DriverId, cancellationToken);
        if (driver is null) return Result.Failure("Driver not found.");

        // Phone uniqueness — reject if another driver owns this number.
        if (!string.IsNullOrWhiteSpace(request.PhoneNumber)
            && !string.Equals(driver.PhoneNumber, request.PhoneNumber, StringComparison.Ordinal))
        {
            var phoneTaken = await _context.Drivers
                .AnyAsync(d => !d.IsDeleted && d.Id != request.DriverId && d.PhoneNumber == request.PhoneNumber, cancellationToken);
            if (phoneTaken)
                return Result.Failure($"Phone '{request.PhoneNumber}' is already used by another driver.");
            driver.PhoneNumber = request.PhoneNumber;
        }
        if (!string.IsNullOrWhiteSpace(request.FullName))   driver.FullName   = request.FullName;
        if (request.FullNameEn is not null)                  driver.FullNameEn = request.FullNameEn;
        if (request.IsActive   is bool active)               driver.IsActive   = active;
        if (request.DriverType is SmartBus.Domain.Enums.DriverType type) driver.DriverType = type;

        await _unitOfWork.Drivers.UpdateAsync(driver);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
