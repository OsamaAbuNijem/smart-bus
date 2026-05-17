using FluentValidation;

namespace SmartBus.Application.Features.Assistants.Commands.CreateAssistant;

public class CreateAssistantCommandValidator : AbstractValidator<CreateAssistantCommand>
{
    public CreateAssistantCommandValidator()
    {
        RuleFor(x => x.FullName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .MaximumLength(20)
            .Matches(@"^(\+962|0)?7[789]\d{7}$")
            .WithMessage("Phone must be a Jordan mobile: 9-digit local part starting with 77, 78, or 79 (the '+962' prefix is implicit).");
    }
}
