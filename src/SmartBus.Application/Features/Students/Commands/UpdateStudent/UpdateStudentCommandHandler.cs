using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Students.Commands.UpdateStudent;

public class UpdateStudentCommandHandler : IRequestHandler<UpdateStudentCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateStudentCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(UpdateStudentCommand request, CancellationToken cancellationToken)
    {
        var student = await _unitOfWork.Students.GetByIdAsync(request.StudentId, cancellationToken);
        if (student is null) return Result.Failure("Student not found.");

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
