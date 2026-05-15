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
    private readonly IActiveSubscriptionService _activeSubscription;

    public CreateStudentCommandHandler(
        IUnitOfWork unitOfWork,
        IApplicationDbContext context,
        IParentUpsertService parentUpsert,
        IActiveSubscriptionService activeSubscription)
    {
        _unitOfWork         = unitOfWork;
        _context            = context;
        _parentUpsert       = parentUpsert;
        _activeSubscription = activeSubscription;
    }

    public async Task<Result<Guid>> Handle(CreateStudentCommand request, CancellationToken cancellationToken)
    {
        // Every new student must land in the school's active subscription
        // window — otherwise the admin panel won't surface them at all.
        if (!Guid.TryParse(request.SchoolId, out var schoolGuid))
            return Result<Guid>.Failure("Invalid school identifier.");

        var activeSubId = await _activeSubscription.GetActiveSubscriptionIdAsync(schoolGuid, cancellationToken);
        if (activeSubId is null)
            return Result<Guid>.Failure(
                "This school has no active subscription. The super admin must create one before students can be added.");

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

        // Link this student to the school's active subscription. New
        // subscription windows reuse the same Student row and just create
        // additional SubscriptionStudent rows.
        _context.SubscriptionStudents.Add(new SubscriptionStudent
        {
            SubscriptionId = activeSubId.Value,
            StudentId      = student.Id
        });

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(student.Id);
    }
}
