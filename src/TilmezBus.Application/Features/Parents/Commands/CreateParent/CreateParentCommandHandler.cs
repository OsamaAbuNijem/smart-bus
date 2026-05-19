using MediatR;
using TilmezBus.Application.Common.Interfaces;
using TilmezBus.Application.Common.Models;
using TilmezBus.Domain.Entities;

namespace TilmezBus.Application.Features.Parents.Commands.CreateParent;

public class CreateParentCommandHandler : IRequestHandler<CreateParentCommand, Result<Guid>>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateParentCommandHandler(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;

    public async Task<Result<Guid>> Handle(CreateParentCommand request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.Parents.GetByPhoneNumberAsync(request.PhoneNumber, cancellationToken);
        if (existing is not null)
            return Result<Guid>.Failure($"Parent with phone '{request.PhoneNumber}' already exists.");

        var parent = new Parent { FullName = request.FullName, PhoneNumber = request.PhoneNumber };
        await _unitOfWork.Parents.AddAsync(parent, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<Guid>.Success(parent.Id);
    }
}
