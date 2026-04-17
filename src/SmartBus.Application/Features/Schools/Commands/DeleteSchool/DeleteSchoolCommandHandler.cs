using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Schools.Commands.DeleteSchool;

public class DeleteSchoolCommandHandler : IRequestHandler<DeleteSchoolCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public DeleteSchoolCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(DeleteSchoolCommand request, CancellationToken cancellationToken)
    {
        var school = await _unitOfWork.Schools.GetByIdAsync(request.SchoolId, cancellationToken);
        if (school is null) return Result.Failure("School not found.");

        await _unitOfWork.Schools.DeleteAsync(school);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
