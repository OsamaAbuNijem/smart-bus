using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;

namespace TilmezBus.Application.Features.Students.Commands.DeleteStudent;

public class DeleteStudentCommandHandler : IRequestHandler<DeleteStudentCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public DeleteStudentCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(DeleteStudentCommand request, CancellationToken cancellationToken)
    {
        var student = await _unitOfWork.Students.GetByIdAsync(request.StudentId, cancellationToken);
        if (student is null) return Result.Failure("Student not found.");

        await _unitOfWork.Students.DeleteAsync(student);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
