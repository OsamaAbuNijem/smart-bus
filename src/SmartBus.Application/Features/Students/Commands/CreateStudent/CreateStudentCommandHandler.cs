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
    private readonly IParentUpsertService _parentUpsert;

    public CreateStudentCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context, IParentUpsertService parentUpsert)
    { _unitOfWork = unitOfWork; _context = context; _parentUpsert = parentUpsert; }

    public async Task<Result<Guid>> Handle(CreateStudentCommand request, CancellationToken cancellationToken)
    {
        if (!string.IsNullOrWhiteSpace(request.NationalNumber))
        {
            var taken = await _context.Students
                .AnyAsync(s => !s.IsDeleted && s.NationalNumber == request.NationalNumber, cancellationToken);
            if (taken)
                return Result<Guid>.Failure($"National number '{request.NationalNumber}' is already used by another student.");
        }

        // Upsert parent (find-by-phone or create) + ensure an Identity user exists.
        var parentId = await _parentUpsert.UpsertAsync(
            request.ParentName, request.ParentPhone, cancellationToken);

        var student = new Student
        {
            SchoolId             = request.SchoolId,
            FullName             = request.FullName,
            FullNameEn           = request.FullNameEn,
            NationalNumber       = request.NationalNumber ?? string.Empty,
            Grade                = request.Grade,
            Class                = request.Class,
            DateOfBirth          = request.DateOfBirth,
            Address              = request.Address,
            ParentId             = parentId,
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
