using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Schools.Commands.CreateSchool;

public class CreateSchoolCommandHandler : IRequestHandler<CreateSchoolCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IUserStore _userStore;

    public CreateSchoolCommandHandler(IUnitOfWork unitOfWork, IUserStore userStore)
    {
        _unitOfWork = unitOfWork;
        _userStore  = userStore;
    }

    public async Task<Result<Guid>> Handle(CreateSchoolCommand request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.Schools.GetByContactEmailAsync(request.ContactEmail, cancellationToken);
        if (existing is not null)
            return Result<Guid>.Failure($"A school with contact email '{request.ContactEmail}' already exists.");

        // Ensure an Admin Identity account exists for the school's admin email
        var (_, userError) = await _userStore.CreateUserIfNotExistsAsync(
            request.AdminEmail,
            request.Name + " Admin",
            request.AdminPassword,
            "Admin",
            cancellationToken);

        if (userError is not null)
            return Result<Guid>.Failure($"Could not create admin account: {userError}");

        var school = new School
        {
            Name          = request.Name,
            City          = request.City,
            ContactEmail  = request.ContactEmail,
            PhoneNumber   = request.PhoneNumber,
            AdminEmail    = request.AdminEmail,
            Plan          = request.Plan,
            MaxBuses      = request.MaxBuses,
            MaxDrivers    = request.MaxDrivers,
            MaxAssistants = request.MaxAssistants,
            MaxStudents   = request.MaxStudents,
            Notes         = request.Notes
        };

        await _unitOfWork.Schools.AddAsync(school, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(school.Id);
    }
}
