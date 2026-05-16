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
            Name        = request.Name,
            City        = request.City,
            PhoneNumber = request.PhoneNumber,
            AdminEmail  = request.AdminEmail,
            ContactName = request.ContactName,
            Latitude    = request.Latitude,
            Longitude   = request.Longitude,
            LogoUrl     = request.LogoUrl
        };

        await _unitOfWork.Schools.AddAsync(school, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // Initial active subscription — the subscription is now the source of
        // truth for MaxStudents / MaxBuses (those columns were removed from
        // School). Super admin can renew/edit via the subscriptions page.
        var subscription = new Subscription
        {
            SchoolId         = school.Id,
            MaxStudents      = request.SubscriptionMaxStudents,
            MaxBuses         = request.SubscriptionMaxBuses,
            ActivationDate   = request.SubscriptionActivationDate,
            ExpirationDate   = request.SubscriptionExpirationDate,
            IsActive         = true,
            Price            = request.SubscriptionPrice,
            // Brand-new sub has no payments — both PaymentStatus and
            // RemainingAmount are server-derived from the payments log.
            PaymentStatus    = SmartBus.Domain.Enums.PaymentStatus.Unpaid,
            RemainingAmount  = request.SubscriptionPrice,
            SubscriptionType = request.SubscriptionType
        };
        _context.Subscriptions.Add(subscription);
        await _context.SaveChangesAsync(cancellationToken);

        // Pre-mint registration QRs in fixed pools. Schools used to declare
        // their own driver / assistant caps; with those gone we mint a
        // generous pool up front and the admin can ignore the unused tokens.
        const int driverPoolSize    = 30;
        const int assistantPoolSize = 30;
        for (var i = 0; i < driverPoolSize; i++)
        {
            _context.EmployeeQrTokens.Add(new EmployeeQrToken
            {
                Token    = Guid.NewGuid().ToString("N"),
                SchoolId = school.Id,
                Type     = EmployeeQrTokenType.Driver
            });
        }
        for (var i = 0; i < assistantPoolSize; i++)
        {
            _context.EmployeeQrTokens.Add(new EmployeeQrToken
            {
                Token    = Guid.NewGuid().ToString("N"),
                SchoolId = school.Id,
                Type     = EmployeeQrTokenType.Assistant
            });
        }
        // Pre-mint a registration QR per student slot. The first scan binds
        // the QR to a real Student row (parent submits the details); later
        // scans from the bus mark boarding/alighting + attendance.
        for (var i = 0; i < request.SubscriptionMaxStudents; i++)
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
