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
        if (!string.Equals(driver.PhoneNumber, request.PhoneNumber, StringComparison.Ordinal))
        {
            var phoneTaken = await _context.Drivers
                .AnyAsync(d => !d.IsDeleted && d.Id != request.DriverId && d.PhoneNumber == request.PhoneNumber, cancellationToken);
            if (phoneTaken)
                return Result.Failure($"Phone '{request.PhoneNumber}' is already used by another driver.");
        }

        driver.FullName     = request.FullName;
        driver.FullNameEn   = request.FullNameEn;
        driver.PhoneNumber  = request.PhoneNumber;
        driver.IsActive     = request.IsActive;
        driver.DriverType   = request.DriverType;

        await _unitOfWork.Drivers.UpdateAsync(driver);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
