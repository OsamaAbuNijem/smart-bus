using MediatR;
using Microsoft.EntityFrameworkCore;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;
using SmartBus.Domain.Entities;
using SmartBus.Domain.Enums;

namespace SmartBus.Application.Features.Schools.Commands.UpdateSchool;

public class UpdateSchoolCommandHandler : IRequestHandler<UpdateSchoolCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IApplicationDbContext _context;

    public UpdateSchoolCommandHandler(IUnitOfWork unitOfWork, IApplicationDbContext context)
    {
        _unitOfWork = unitOfWork;
        _context    = context;
    }

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

        // Top up registration tokens if the school's limits were raised. Never
        // delete on shrink — once issued, a token can be redeemed or stays in
        // the printable list until the SuperAdmin manually invalidates it.
        await TopUpEmployeeTokensAsync(school.Id, EmployeeQrTokenType.Driver,    school.MaxDrivers,    cancellationToken);
        await TopUpEmployeeTokensAsync(school.Id, EmployeeQrTokenType.Assistant, school.MaxAssistants, cancellationToken);
        await TopUpStudentTokensAsync (school.Id,                                school.MaxStudents,   cancellationToken);

        return Result.Success();
    }

    private async Task TopUpEmployeeTokensAsync(Guid schoolId, EmployeeQrTokenType type, int target, CancellationToken ct)
    {
        var current = await _context.EmployeeQrTokens
            .CountAsync(t => t.SchoolId == schoolId && t.Type == type, ct);
        var deficit = target - current;
        if (deficit <= 0) return;

        for (var i = 0; i < deficit; i++)
        {
            _context.EmployeeQrTokens.Add(new EmployeeQrToken
            {
                Token    = Guid.NewGuid().ToString("N"),
                SchoolId = schoolId,
                Type     = type
            });
        }
        await _context.SaveChangesAsync(ct);
    }

    private async Task TopUpStudentTokensAsync(Guid schoolId, int target, CancellationToken ct)
    {
        var current = await _context.StudentQrTokens
            .CountAsync(t => t.SchoolId == schoolId, ct);
        var deficit = target - current;
        if (deficit <= 0) return;

        for (var i = 0; i < deficit; i++)
        {
            _context.StudentQrTokens.Add(new StudentQrToken
            {
                Token    = Guid.NewGuid().ToString("N"),
                SchoolId = schoolId
            });
        }
        await _context.SaveChangesAsync(ct);
    }
}
