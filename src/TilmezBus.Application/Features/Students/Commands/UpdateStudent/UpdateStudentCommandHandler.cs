using MediatR;
using Microsoft.EntityFrameworkCore;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Commands.UpdateStudent;

public class UpdateStudentCommandHandler : IRequestHandler<UpdateStudentCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;
    private readonly IParentUpsertService _parentUpsert;

    public UpdateStudentCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context, IParentUpsertService parentUpsert)
    { _unitOfWork = unitOfWork; _context = context; _parentUpsert = parentUpsert; }

    public async Task<Result> Handle(UpdateStudentCommand request, CancellationToken cancellationToken)
    {
        var student = await _unitOfWork.Students.GetByIdAsync(request.StudentId, cancellationToken);
        if (student is null) return Result.Failure("Student not found.");

        if (!string.IsNullOrWhiteSpace(request.NationalNumber) &&
            !string.Equals(student.NationalNumber, request.NationalNumber, StringComparison.Ordinal))
        {
            var taken = await _context.Students
                .AnyAsync(s => !s.IsDeleted && s.Id != request.StudentId && s.NationalNumber == request.NationalNumber, cancellationToken);
            if (taken)
                return Result.Failure($"National number '{request.NationalNumber}' is already used by another student.");
        }

        // Upsert parent + ensure user exists. May produce a new Parent if the phone changed;
        // the old Parent row is left intact (it may still belong to siblings).
        var parentId = await _parentUpsert.UpsertAsync(
            request.ParentName, request.ParentPhone, cancellationToken);

        student.FullName       = request.FullName;
        student.FullNameEn     = request.FullNameEn;
        student.NationalNumber = request.NationalNumber ?? string.Empty;
        student.Grade          = request.Grade;
        student.Class          = request.Class;
        student.DateOfBirth    = request.DateOfBirth;
        student.Address        = request.Address;
        student.ParentId       = parentId;
        student.RouteId        = request.RouteId;
        student.PickupStopId   = request.PickupStopId;
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
