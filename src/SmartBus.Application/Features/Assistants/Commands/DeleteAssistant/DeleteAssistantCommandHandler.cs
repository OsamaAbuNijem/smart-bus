using MediatR;
using SmartBus.Application.Common.Interfaces;
using SmartBus.Application.Common.Models;

namespace SmartBus.Application.Features.Assistants.Commands.DeleteAssistant;

public class DeleteAssistantCommandHandler : IRequestHandler<DeleteAssistantCommand, Result>
{
    private readonly IUnitOfWork _unitOfWork;

    public DeleteAssistantCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result> Handle(DeleteAssistantCommand request, CancellationToken cancellationToken)
    {
        var assistant = await _unitOfWork.Assistants.GetByIdAsync(request.AssistantId, cancellationToken);
        if (assistant is null) return Result.Failure("Assistant not found.");

        await _unitOfWork.Assistants.DeleteAsync(assistant);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Success();
    }
}
