using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Drivers.Commands.UpdateMyProfile;

public class UpdateMyProfileCommandHandler
    : IRequestHandler<UpdateMyProfileCommand, Result<UpdateMyProfileResponse>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public UpdateMyProfileCommandHandler(
        IApplicationDbContext context,
        ICurrentUserService currentUser)
    {
        _context     = context;
        _currentUser = currentUser;
    }

    public async Task<Result<UpdateMyProfileResponse>> Handle(
        UpdateMyProfileCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        if (string.IsNullOrEmpty(userId))
            return Result<UpdateMyProfileResponse>.Failure("Unauthenticated.");

        var fullName = request.FullName?.Trim();
        var phone    = request.PhoneNumber?.Trim();

        if (string.IsNullOrWhiteSpace(fullName))
            return Result<UpdateMyProfileResponse>.Failure("Full name is required.");
        if (string.IsNullOrWhiteSpace(phone))
            return Result<UpdateMyProfileResponse>.Failure("Phone number is required.");

        var driver = await _context.Drivers
            .FirstOrDefaultAsync(d => d.UserId == userId, ct);
        if (driver is null)
            return Result<UpdateMyProfileResponse>.Failure("Driver record not found.");

        // Phone must remain unique across the Drivers table.
        if (!string.Equals(driver.PhoneNumber, phone, StringComparison.Ordinal))
        {
            var conflict = await _context.Drivers
                .AnyAsync(d => d.Id != driver.Id && d.PhoneNumber == phone, ct);
            if (conflict)
                return Result<UpdateMyProfileResponse>.Failure(
                    "Phone number is already in use.");
        }

        driver.FullName    = fullName!;
        driver.PhoneNumber = phone!;
        await _context.SaveChangesAsync(ct);

        return Result<UpdateMyProfileResponse>.Success(
            new UpdateMyProfileResponse(driver.Id, driver.FullName, driver.PhoneNumber));
    }
}
