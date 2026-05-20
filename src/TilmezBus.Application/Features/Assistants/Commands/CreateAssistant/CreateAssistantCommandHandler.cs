using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Common.Utilities;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Assistants.Commands.CreateAssistant;

public class CreateAssistantCommandHandler : IRequestHandler<CreateAssistantCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateAssistantCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(CreateAssistantCommand request, CancellationToken cancellationToken)
    {
        // Canonicalise so storage matches OTP lookups (+9627XXXXXXXX).
        var phone = PhoneNumberHelper.Normalize(request.PhoneNumber);

        var existing = await _unitOfWork.Assistants.GetByPhoneNumberAsync(phone, cancellationToken);
        if (existing is not null)
            return Result<Guid>.Failure($"Assistant with phone '{phone}' already exists.");

        var assistant = new Assistant { FullName = request.FullName, PhoneNumber = phone };
        await _unitOfWork.Assistants.AddAsync(assistant, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(assistant.Id);
    }
}
