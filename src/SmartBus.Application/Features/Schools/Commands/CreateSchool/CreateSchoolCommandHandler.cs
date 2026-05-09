using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Schools.Commands.CreateSchool;

public class CreateSchoolCommandHandler : IRequestHandler<CreateSchoolCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IUserStore _userStore;
    private readonly IApplicationDbContext _context;

    public CreateSchoolCommandHandler(IUnitOfWork unitOfWork, IUserStore userStore, IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _userStore  = userStore;
        _context    = context;
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
            Notes         = request.Notes,
            Latitude      = request.Latitude,
            Longitude     = request.Longitude
        };

        await _unitOfWork.Schools.AddAsync(school, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // Pre-mint a registration QR for every driver/assistant slot the school is
        // entitled to. Each token is single-use and the type determines what the
        // mobile app creates when the employee scans it for the first time.
        for (var i = 0; i < school.MaxDrivers; i++)
        {
            _context.EmployeeQrTokens.Add(new EmployeeQrToken
            {
                Token    = Guid.NewGuid().ToString("N"),
                SchoolId = school.Id,
                Type     = EmployeeQrTokenType.Driver
            });
        }
        for (var i = 0; i < school.MaxAssistants; i++)
        {
            _context.EmployeeQrTokens.Add(new EmployeeQrToken
            {
                Token    = Guid.NewGuid().ToString("N"),
                SchoolId = school.Id,
                Type     = EmployeeQrTokenType.Assistant
            });
        }
        // Pre-mint a registration QR per student slot. The first scan binds the
        // QR to a real Student row (parent submits the details); every later
        // scan from the bus marks boarding/alighting + attendance.
        for (var i = 0; i < school.MaxStudents; i++)
        {
            _context.StudentQrTokens.Add(new StudentQrToken
            {
                Token    = Guid.NewGuid().ToString("N"),
                SchoolId = school.Id
            });
        }
        await _context.SaveChangesAsync(cancellationToken);

        return Result<Guid>.Success(school.Id);
    }
}
