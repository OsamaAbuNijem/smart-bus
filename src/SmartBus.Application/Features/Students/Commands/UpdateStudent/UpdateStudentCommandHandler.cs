using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Commands.UpdateStudent;

public class UpdateStudentCommandHandler : IRequestHandler<UpdateStudentCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public UpdateStudentCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    { _unitOfWork = unitOfWork; _context = context; }

    public async Task<Result> Handle(UpdateStudentCommand request, CancellationToken cancellationToken)
    {
        var student = await _unitOfWork.Students.GetByIdAsync(request.StudentId, cancellationToken);
        if (student is null) return Result.Failure("Student not found.");

        // Parent phone must be unique — reject if another student already has it.
        if (!string.Equals(student.ParentPhone, request.ParentPhone, StringComparison.Ordinal))
        {
            var phoneTaken = await _context.Students
                .AnyAsync(s => !s.IsDeleted && s.Id != request.StudentId && s.ParentPhone == request.ParentPhone, cancellationToken);
            if (phoneTaken)
                return Result.Failure($"Parent phone '{request.ParentPhone}' is already used by another student.");
        }

        student.FullName     = request.FullName;
        student.FullNameEn   = request.FullNameEn;
        student.Grade        = request.Grade;
        student.Class        = request.Class;
        student.DateOfBirth  = request.DateOfBirth;
        student.Address      = request.Address;
        student.ParentName   = request.ParentName;
        student.ParentNameEn = request.ParentNameEn;
        student.ParentPhone  = request.ParentPhone;
        student.RouteId      = request.RouteId;
        student.PickupStopId = request.PickupStopId;
        student.Latitude             = request.Latitude;
        student.Longitude            = request.Longitude;
        student.HomeArea             = request.HomeArea;
        student.HomeStreet           = request.HomeStreet;
        student.HomeBuildingNumber   = request.HomeBuildingNumber;

        await _unitOfWork.Students.UpdateAsync(student);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
