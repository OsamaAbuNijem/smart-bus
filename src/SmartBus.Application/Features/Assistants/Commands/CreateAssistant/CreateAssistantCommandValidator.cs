using FluentValidation;

namespace SmartBus.Application.Features.Assistants.Commands.CreateAssistant;

public class CreateAssistantCommandValidator : AbstractValidator<CreateAssistantCommand>
{
    public CreateAssistantCommandValidator()
    {
        RuleFor(x => x.FullName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.PhoneNumber).NotEmpty().MaximumLength(20);
    }
}
