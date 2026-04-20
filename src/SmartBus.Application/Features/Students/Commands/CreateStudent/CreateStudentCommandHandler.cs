using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;

namespace SmartBus.Application.Features.Students.Commands.CreateStudent;

public class CreateStudentCommandHandler : IRequestHandler<CreateStudentCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public CreateStudentCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    { _unitOfWork = unitOfWork; _context = context; }

    public async Task<Result<Guid>> Handle(CreateStudentCommand request, CancellationToken cancellationToken)
    {
        // Parent phone must be unique across (non-deleted) students.
        var phoneTaken = await _context.Students
            .AnyAsync(s => !s.IsDeleted && s.ParentPhone == request.ParentPhone, cancellationToken);
        if (phoneTaken)
            return Result<Guid>.Failure($"Parent phone '{request.ParentPhone}' is already used by another student.");

        var student = new Student
        {
            SchoolId             = request.SchoolId,
            FullName             = request.FullName,
            FullNameEn           = request.FullNameEn,
            Grade                = request.Grade,
            Class                = request.Class,
            DateOfBirth          = request.DateOfBirth,
            Address              = request.Address,
            ParentName           = request.ParentName,
            ParentNameEn         = request.ParentNameEn,
            ParentPhone          = request.ParentPhone,
            ParentId             = request.ParentId,
            RouteId              = request.RouteId,
            PickupStopId         = request.PickupStopId,
            Latitude             = request.Latitude,
            Longitude            = request.Longitude,
            HomeArea             = request.HomeArea,
            HomeStreet           = request.HomeStreet,
            HomeBuildingNumber   = request.HomeBuildingNumber
        };

        await _unitOfWork.Students.AddAsync(student, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(student.Id);
    }
}
