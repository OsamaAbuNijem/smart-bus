using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Common.Utilities;

namespace TilmezBus.Application.Features.Drivers.Commands.UpdateDriver;

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
        // Canonicalise to +9627XXXXXXXX so storage matches OTP lookups.
        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            var newPhone = PhoneNumberHelper.Normalize(request.PhoneNumber);
            if (!string.Equals(driver.PhoneNumber, newPhone, StringComparison.Ordinal))
            {
                var phoneTaken = await _context.Drivers
                    .AnyAsync(d => !d.IsDeleted && d.Id != request.DriverId && d.PhoneNumber == newPhone, cancellationToken);
                if (phoneTaken)
                    return Result.Failure($"Phone '{newPhone}' is already used by another driver.");
                driver.PhoneNumber = newPhone;
            }
        }
        if (!string.IsNullOrWhiteSpace(request.FullName))   driver.FullName   = request.FullName;
        if (request.FullNameEn is not null)                  driver.FullNameEn = request.FullNameEn;
        if (request.IsActive   is bool active)               driver.IsActive   = active;
        if (request.DriverType is TilmezBus.Domain.Enums.DriverType type) driver.DriverType = type;

        await _unitOfWork.Drivers.UpdateAsync(driver);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
