using FluentValidation;

namespace SmartBus.Application.Features.Parents.Commands.CreateParent;

public class CreateParentCommandValidator : AbstractValidator<CreateParentCommand>
{
    public CreateParentCommandValidator()
    {
        RuleFor(x => x.FullName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.PhoneNumber).NotEmpty().MaximumLength(20);
    }
}
