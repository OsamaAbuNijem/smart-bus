using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Application.Common.Utilities;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Parents.Commands.CreateParent;

public class CreateParentCommandHandler : IRequestHandler<CreateParentCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateParentCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(CreateParentCommand request, CancellationToken cancellationToken)
    {
        // Canonicalise so storage matches OTP lookups (+9627XXXXXXXX).
        var phone = PhoneNumberHelper.Normalize(request.PhoneNumber);

        var existing = await _unitOfWork.Parents.GetByPhoneNumberAsync(phone, cancellationToken);
        if (existing is not null)
            return Result<Guid>.Failure($"Parent with phone '{phone}' already exists.");

        var parent = new Parent { FullName = request.FullName, PhoneNumber = phone };
        await _unitOfWork.Parents.AddAsync(parent, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(parent.Id);
    }
}
