using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Parents.Commands.DeleteParent;

public class DeleteParentCommandHandler : IRequestHandler<DeleteParentCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public DeleteParentCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(DeleteParentCommand request, CancellationToken cancellationToken)
    {
        var parent = await _unitOfWork.Parents.GetByIdAsync(request.ParentId, cancellationToken);
        if (parent is null) return Result.Failure("Parent not found.");

        await _unitOfWork.Parents.DeleteAsync(parent);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
