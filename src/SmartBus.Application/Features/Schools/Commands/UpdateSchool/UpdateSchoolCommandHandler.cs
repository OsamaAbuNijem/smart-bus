using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Schools.Commands.UpdateSchool;

public class UpdateSchoolCommandHandler : IRequestHandler<UpdateSchoolCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateSchoolCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(UpdateSchoolCommand request, CancellationToken cancellationToken)
    {
        var school = await _unitOfWork.Schools.GetByIdAsync(request.SchoolId, cancellationToken);
        if (school is null) return Result.Failure("School not found.");

        var existing = await _unitOfWork.Schools.GetByContactEmailAsync(request.ContactEmail, cancellationToken);
        if (existing is not null && existing.Id != request.SchoolId)
            return Result.Failure($"Email '{request.ContactEmail}' is already used by another school.");

        school.Name          = request.Name;
        school.City          = request.City;
        school.ContactEmail  = request.ContactEmail;
        school.PhoneNumber   = request.PhoneNumber;
        school.AdminEmail    = request.AdminEmail;
        school.Plan          = request.Plan;
        school.MaxBuses      = request.MaxBuses;
        school.MaxDrivers    = request.MaxDrivers;
        school.MaxAssistants = request.MaxAssistants;
        school.MaxStudents   = request.MaxStudents;
        school.IsActive      = request.IsActive;
        school.Notes         = request.Notes;

        await _unitOfWork.Schools.UpdateAsync(school);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
