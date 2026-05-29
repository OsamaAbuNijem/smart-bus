using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Schools.Commands.UpdateSchool;

public class UpdateSchoolCommandHandler : IRequestHandler<UpdateSchoolCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IUserStore  _userStore;

    public UpdateSchoolCommandHandler(IUnitOfWork unitOfWork, IUserStore userStore)
    {
        _unitOfWork = unitOfWork;
        _userStore  = userStore;
    }

    public async Task<Result> Handle(UpdateSchoolCommand request, CancellationToken cancellationToken)
    {
        var school = await _unitOfWork.Schools.GetByIdAsync(request.SchoolId, cancellationToken);
        if (school is null) return Result.Failure("School not found.");

        // Rename the matching Identity user FIRST so login + forgot-password
        // keep working against the new address. If Identity rejects the
        // change (e.g. the new email is already taken by another account)
        // bail before mutating the school row.
        var oldEmail = school.AdminEmail;
        var newEmail = request.AdminEmail;
        if (!string.Equals(oldEmail, newEmail, StringComparison.OrdinalIgnoreCase))
        {
            var (ok, err) = await _userStore.ChangeEmailAsync(oldEmail, newEmail, cancellationToken);
            if (!ok) return Result.Failure(err ?? "Could not rename the admin account.");
        }

        school.Name        = request.Name;
        school.City        = request.City;
        school.PhoneNumber = request.PhoneNumber;
        school.AdminEmail  = newEmail;
        school.ContactName = request.ContactName;
        // Coordinates / logo: null on update means "leave as-is". The form
        // always submits both lat+lng together when the map picker is used,
        // and submits LogoUrl only when a new logo has been uploaded.
        if (request.Latitude  is not null) school.Latitude  = request.Latitude;
        if (request.Longitude is not null) school.Longitude = request.Longitude;
        if (request.LogoUrl   is not null) school.LogoUrl   = request.LogoUrl;

        await _unitOfWork.Schools.UpdateAsync(school);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
