using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Common.Utilities;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Drivers.Commands.CreateDriver;

public class CreateDriverCommandHandler : IRequestHandler<CreateDriverCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public CreateDriverCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    { _unitOfWork = unitOfWork; _context = context; }

    public async Task<Result<Guid>> Handle(CreateDriverCommand request, CancellationToken cancellationToken)
    {
        // Canonicalise the phone so all DB rows store the +9627XXXXXXXX form.
        // Mobile clients send +962…; admin web typed values may be local
        // ("079…" / "79…"). Without this, the OTP lookup later sees a literal
        // string mismatch and "phone not found in the system" is returned.
        var phone = PhoneNumberHelper.Normalize(request.PhoneNumber);

        var phoneTaken = await _context.Drivers
            .AnyAsync(d => !d.IsDeleted && d.PhoneNumber == phone, cancellationToken);
        if (phoneTaken)
            return Result<Guid>.Failure($"Phone '{phone}' is already used by another driver.");

        var driver = new Driver
        {
            FullName    = request.FullName,
            FullNameEn  = request.FullNameEn,
            PhoneNumber = phone,
            IsActive    = request.IsActive,
            DriverType  = request.DriverType,
            SchoolId    = request.SchoolId
        };

        await _unitOfWork.Drivers.AddAsync(driver, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(driver.Id);
    }
}
