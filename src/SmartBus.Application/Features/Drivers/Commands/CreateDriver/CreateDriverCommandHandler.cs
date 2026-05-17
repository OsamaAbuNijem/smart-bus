using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Drivers.Commands.CreateDriver;

public class CreateDriverCommandHandler : IRequestHandler<CreateDriverCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public CreateDriverCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    { _unitOfWork = unitOfWork; _context = context; }

    public async Task<Result<Guid>> Handle(CreateDriverCommand request, CancellationToken cancellationToken)
    {
        // Phone number must be unique across non-deleted drivers.
        var phoneTaken = await _context.Drivers
            .AnyAsync(d => !d.IsDeleted && d.PhoneNumber == request.PhoneNumber, cancellationToken);
        if (phoneTaken)
            return Result<Guid>.Failure($"Phone '{request.PhoneNumber}' is already used by another driver.");

        var driver = new Driver
        {
            FullName    = request.FullName,
            FullNameEn  = request.FullNameEn,
            PhoneNumber = request.PhoneNumber,
            IsActive    = request.IsActive,
            DriverType  = request.DriverType,
            SchoolId    = request.SchoolId
        };

        await _unitOfWork.Drivers.AddAsync(driver, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(driver.Id);
    }
}
