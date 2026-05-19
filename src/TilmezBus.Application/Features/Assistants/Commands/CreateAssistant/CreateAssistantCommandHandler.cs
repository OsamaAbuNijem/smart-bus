using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Assistants.Commands.CreateAssistant;

public class CreateAssistantCommandHandler : IRequestHandler<CreateAssistantCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateAssistantCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(CreateAssistantCommand request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.Assistants.GetByPhoneNumberAsync(request.PhoneNumber, cancellationToken);
        if (existing is not null)
            return Result<Guid>.Failure($"Assistant with phone '{request.PhoneNumber}' already exists.");

        var assistant = new Assistant { FullName = request.FullName, PhoneNumber = request.PhoneNumber };
        await _unitOfWork.Assistants.AddAsync(assistant, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(assistant.Id);
    }
}
